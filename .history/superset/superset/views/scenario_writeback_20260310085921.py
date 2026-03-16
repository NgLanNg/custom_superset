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
"""
Custom View for Scenario Write-back (SQLite MVP version).
Uses BaseSupersetView to satisfy authentication and authorization requirements.
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Any

from flask import jsonify, request
from flask_appbuilder import expose
from flask_appbuilder.security.decorators import has_access_api
from flask_login import current_user
from sqlalchemy import text

from superset import db
from superset.views.base import BaseSupersetView

logger = logging.getLogger(__name__)

# Field length limits — prevents oversized payloads reaching the DB
_MAX_FIELD_LEN = 128


class ScenarioWritebackView(BaseSupersetView):
    route_base = "/api/v1/scenario"

    @has_access_api
    @expose("/writeback", methods=("POST",))
    def writeback(self) -> Any:
        """
        Receive a cell edit from the Scenario UI and persist it to SQLite.
        """
        payload: dict[str, Any] = request.get_json(silent=True, force=True) or {}

        required = ["scenario_name", "bu", "opu", "year", "value"]
        for field in required:
            if field not in payload:
                return jsonify(
                    {"status": "error", "message": f"Missing field: {field}"}
                ), 400

        # Length validation on text fields to prevent oversized payloads
        for text_field in ("scenario_name", "bu", "opu"):
            val = payload.get(text_field, "")
            if not isinstance(val, str) or not val.strip():
                return jsonify({"status": "error", "message": f"{text_field} must be a non-empty string"}), 400
            if len(val) > _MAX_FIELD_LEN:
                return jsonify({"status": "error", "message": f"{text_field} exceeds max length of {_MAX_FIELD_LEN}"}), 400

        try:
            value = float(payload.get("value", 0))
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": "Value must be a number"}), 400

        if not (0 <= value <= 100):
            return jsonify(
                {"status": "error", "message": "Value must be between 0 and 100"}
            ), 400

        # Try to gather useful user info from context
        # current_user is authenticated via @has_access_api
        user_email = "anonymous@local"
        if hasattr(current_user, "email") and current_user.email:
            user_email = current_user.email
        elif hasattr(current_user, "username") and current_user.username:
            user_email = current_user.username

        # SQLite compatible UPSERT (INSERT ... ON CONFLICT DO UPDATE)
        stmt = text(
            """
            INSERT INTO silver_scenario_equity_share (
                id, scenario_name, bu, opu, year, value, scenario_id, user_email, updated_at
            ) VALUES (
                :id, :scen, :bu, :opu, :yr, :val, :sid, :email, :ts
            )
            ON CONFLICT(scenario_name, opu, year, scenario_id, user_email)
            DO UPDATE SET
                value = excluded.value,
                updated_at = excluded.updated_at;
            """
        )

        try:
            db.session.execute(
                stmt,
                {
                    "id": str(uuid.uuid4()),
                    "scen": payload["scenario_name"],
                    "bu": payload["bu"],
                    "opu": payload["opu"],
                    "yr": payload["year"],
                    "val": value,
                    # H2 Fix: Use empty string instead of None (NULL) to satisfy NOT NULL constraint
                    # and ensure ON CONFLICT triggers correctly in SQLite.
                    "sid": payload.get("scenario_id") or "",
                    "email": user_email,
                    "ts": datetime.now(timezone.utc),
                },
            )
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logger.error("Failed to upsert scenario data: %s", e, exc_info=True)
            return jsonify({"status": "error", "message": "Database write failed. See server logs."}), 500

        return self.json_response(
            {
                "status": "success",
                "data": {
                    "opu": payload["opu"],
                    "year": payload["year"],
                    "value": value,
                },
            }
        )

    @expose("/health", methods=("GET",))
    def health(self) -> Any:
        return self.json_response({"status": "ok", "view": "scenario", "db": "sqlite"})
