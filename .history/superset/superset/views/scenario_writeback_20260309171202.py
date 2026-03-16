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
Custom Flask Blueprint for Scenario Write-back (SQLite MVP version).
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Any

from flask import Blueprint, jsonify, request

# In a real Superset env, we would use @protect().
# For local UX test, we can leave it open or use it.
from flask_login import current_user
from sqlalchemy import text

# Import Superset's global DB session
from superset import db
from superset.views.base import BaseSupersetView  # noqa: F401 — ensures AppBuilder context
from flask_appbuilder.security.decorators import protect

logger = logging.getLogger(__name__)

scenario_bp = Blueprint("scenario", __name__, url_prefix="/api/v1/scenario")

# Field length limits — prevents oversized payloads reaching the DB
_MAX_FIELD_LEN = 128


@scenario_bp.route("/writeback", methods=["POST"])
@protect()  # Critical C1: Ensures only authenticated users can write data
def writeback() -> Any:
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

    user_email = (
        current_user.email
        if hasattr(current_user, "email")
        else "anonymous@local"
    )

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
                # Use None (SQL NULL) for absent scenario_id to avoid breaking
                # the UNIQUE constraint which treats each empty-string as equal
                "sid": payload.get("scenario_id") or None,
                "email": user_email,
                "ts": datetime.now(timezone.utc),
            },
        )
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        logger.error("Failed to upsert scenario data: %s", e, exc_info=True)
        # Do NOT expose raw exception detail — log server-side, return generic message
        return jsonify({"status": "error", "message": "Database write failed. See server logs."}), 500

    return (
        jsonify(
            {
                "status": "success",
                "data": {
                    "opu": payload["opu"],
                    "year": payload["year"],
                    "value": value,
                },
            }
        ),
        200,
    )


@scenario_bp.route("/health", methods=["GET"])
def health() -> Any:
    return (
        jsonify({"status": "ok", "blueprint": "scenario", "db": "sqlite"}),
        200,
    )
