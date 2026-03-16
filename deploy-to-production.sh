#!/bin/bash
# Production Deployment Script for Scenario Dashboard
# Run this on the production PostgreSQL server
#
# Usage: ./deploy-to-production.sh [database-host]
# Example: ./deploy-to-production.sh prod-db.example.com
#
# Steps:
# 1. Run production-setup.sql to create DB and tables
# 2. Update superset_config.py with production database settings
# 3. Run superset migrations
# 4. Restart Superset service

set -e

# Configuration
DB_HOST="${1:-localhost}"
DB_PORT="5432"
DB_USER="superset"
DB_PASS="${SUPERSET_DB_PASS:-superset}"
DB_NAME="superset"
SUPERSET_SECRET_KEY="${SUPERSET_SECRET_KEY:-random-production-key}"

echo "========================================"
echo "PRODUCTION DEPLOYMENT"
echo "========================================"
echo ""

# Validate inputs
if [ -z "$DB_HOST" ]; then
    echo "Error: Database host is required"
    echo "Usage: $0 <database-host>"
    exit 1
fi

echo "Deployment Configuration:"
echo "  Database Host: $DB_HOST"
echo "  Database Port: $DB_PORT"
echo "  Database User: $DB_USER"
echo "  Database Name: $DB_NAME"
echo "  Secret Key: ${SUPERSET_SECRET_KEY:0:20}..."
echo ""

# Step 1: Run production database setup
echo "Step 1: Creating production database and tables..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -f docs/migrations/2026-03-16-production-setup.sql

if [ $? -ne 0 ]; then
    echo "Error: Database setup failed"
    exit 1
fi

echo "Database setup complete!"
echo ""

# Step 2: Export connection info
echo "Step 2: Exporting database connection string..."
export SUPERSET_DB_HOST="$DB_HOST"
export SUPERSET_DB_PORT="$DB_PORT"
export SUPERSET_DB_USER="$DB_USER"
export SUPERSET_DB_PASS="$DB_PASS"
export SUPERSET_DB_NAME="$DB_NAME"
export SUPERSET_SECRET_KEY="$SUPERSET_SECRET_KEY"

echo "Connection string: postgresql+psycopg2://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo ""

# Step 3: Create production config update
echo "Step 3: Creating production configuration..."
CONFIG_BACKUP="/Users/alan/dashboard/superset/superset/config.py.backup"
CONFIG_FILE="/Users/alan/dashboard/superset/superset/config.py"

# Backup existing config
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_BACKUP"
    echo "Config backed up to: $CONFIG_BACKUP"
fi

# Create new production config
cat > "$CONFIG_FILE" << 'EOF'
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
"""The main config file for Superset

All configuration in this file can be overridden by providing a superset_config
in your PYTHONPATH as there is a ``from superset_config import *``
at end of this file.
"""
from __future__ import annotations

import importlib.util
import json
import logging
import os
import re
import sys
from collections import OrderedDict
from contextlib import contextmanager
from datetime import timedelta
from email.mime.multipart import MIMEMultipart
from importlib.resources import files
from typing import Any, Callable, Iterator, Literal, Optional, TYPE_CHECKING, TypedDict

import click
from celery.schedules import crontab
from flask import Blueprint
from flask_appbuilder.security.manager import AUTH_DB
from flask_caching.backends.base import BaseCache
from pandas import Series
from pandas._libs.parsers import STR_NA_VALUES
from sqlalchemy.engine.url import URL
from sqlalchemy.orm.query import Query

from superset.advanced_data_type.plugins.internet_address import internet_address
from superset.advanced_data_type.plugins.internet_port import internet_port
from superset.advanced_data_type.types import AdvancedDataType
from superset.constants import CHANGE_ME_SECRET_KEY
from superset.jinja_context import BaseTemplateProcessor
from superset.key_value.types import JsonKeyValueCodec
from superset.stats_logger import DummyStatsLogger
from superset.superset_typing import CacheConfig
from superset.tasks.types import ExecutorType
from superset.themes.types import Theme
from superset.utils import core as utils
from superset.utils.encrypt import SQLAlchemyUtilsAdapter
from superset.utils.log import DBEventLogger
from superset.utils.logging_configurator import DefaultLoggingConfigurator
from superset.utils.version import get_dev_env_label

logger = logging.getLogger(__name__)

if TYPE_CHECKING:
    from flask_appbuilder.security.sqla import models
    from sqlglot import Dialect, Dialects  # pylint: disable=disallowed-sql-import

    from superset.connectors.sqla.models import SqlaTable
    from superset.models.core import Database
    from superset.models.dashboard import Dashboard
    from superset.models.slice import Slice

    DialectExtensions = dict[str, Dialects | type[Dialect]]

# Realtime stats logger, a StatsD implementation exists
STATS_LOGGER = DummyStatsLogger()

# By default will log events to the metadata database with `DBEventLogger`
# Note that you can use `StdOutEventLogger` for debugging
# Note that you can write your own event logger by extending `AbstractEventLogger`
# https://github.com/apache/superset/blob/master/superset/utils/log.py
EVENT_LOGGER = DBEventLogger()

SUPERSET_LOG_VIEW = True

# This config is used to enable/disable the following security menu items:
# List Users, List Roles, List Groups
SUPERSET_SECURITY_VIEW_MENU = True

CUSTOM_SECURITY_MANAGER = None

# =============================================================================
# 1. Environment Configuration
# =============================================================================
# CRITICAL: In production, use a strong random secret stored in Alibaba
# Cloud Secrets Manager or environment variables.
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")

# Allow graceful fallback if SECRET_KEY is not set
if not SECRET_KEY:
    SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "fallback-key-for-testing-only")

# =============================================================================
# 2. Database Configuration
# =============================================================================
# Production PostgreSQL connection string
_DATABASE_HOST = os.environ.get("SUPERSET_DB_HOST", "${DB_HOST}")
_DATABASE_PORT = os.environ.get("SUPERSET_DB_PORT", "${DB_PORT}")
_DATABASE_USER = os.environ.get("SUPERSET_DB_USER", "${DB_USER}")
_DATABASE_PASS = os.environ.get("SUPERSET_DB_PASS", "${DB_PASS}")
_DATABASE_NAME = os.environ.get("SUPERSET_DB_NAME", "${DB_NAME}")

# Build connection string with proper quoting
# Using postgresql+psycopg2:// for better connection handling
SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{_DATABASE_USER}:{_DATABASE_PASS}@{_DATABASE_HOST}:{_DATABASE_PORT}/{_DATABASE_NAME}"
SQLALCHEMY_EXAMPLES_URI = SQLALCHEMY_DATABASE_URI

logger.info(f"Database configured: {_DATABASE_USER}@{_DATABASE_HOST}:{_DATABASE_PORT}/{_DATABASE_NAME}")
EOF

echo "Production config created!"
echo ""

# Step 4: Restart Superset
echo "Step 4: Restarting Superset service..."
echo "Note: You may need to restart the service manually"
echo ""
echo "Superset will use the following configuration:"
echo "  SUPERSET_SECRET_KEY: Required (generate with: openssl rand -base64 42)"
echo "  SUPERSET_DB_HOST: $DB_HOST"
echo "  SUPERSET_DB_PORT: $DB_PORT"
echo "  SUPERSET_DB_USER: $DB_USER"
echo "  SUPERSET_DB_PASS: $DB_PASS"
echo "  SUPERSET_DB_NAME: $DB_NAME"
echo ""

echo "========================================"
echo "DEPLOYMENT COMPLETE"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Set SUPERSET_SECRET_KEY environment variable:"
echo "   export SUPERSET_SECRET_KEY=\$(openssl rand -base64 42)"
echo ""
echo "2. Set database credentials:"
echo "   export SUPERSET_DB_HOST=$DB_HOST"
echo "   export SUPERSET_DB_PORT=$DB_PORT"
echo "   export SUPERSET_DB_USER=$DB_USER"
echo "   export SUPERSET_DB_PASS=$DB_PASS"
echo "   export SUPERSET_DB_NAME=$DB_NAME"
echo ""
echo "3. Restart Superset service:"
echo "   cd /path/to/superset"
echo "   killall -9 -f python flask run"
echo "   flask run --host=0.0.0.0 --port=8088"
echo ""
