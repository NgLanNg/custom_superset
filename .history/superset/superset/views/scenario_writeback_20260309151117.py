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
Custom Flask Blueprint for Scenario Write-back.

Receives cell edits from the Scenario UI and persists them to the
configured database. Registered via superset_config.py EXTRA_BLUEPRINTS.
"""
from __future__ import annotations

import logging
from typing import Any

from flask import Blueprint, jsonify, request

logger = logging.getLogger(__name__)

scenario_bp = Blueprint("scenario", __name__, url_prefix="/api/v1/scenario")


@scenario_bp.route("/writeback", methods=["POST"])
def writeback() -> Any:
    """
    Receive a cell edit from the Scenario UI and persist it.

    Expected JSON payload::

        {
            "asset":  "MLNG",
            "year":   2020,
            "value":  90,
            "table":  "equity_share_existing"
        }

    Returns a JSON confirmation with the saved values.
    """
    payload: dict[str, Any] = request.get_json(silent=True) or {}

    asset = payload.get("asset")
    year = payload.get("year")
    value = payload.get("value")
    table = payload.get("table", "equity_share_existing")

    if asset is None or year is None or value is None:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    logger.info(
        "Scenario write-back: table=%s asset=%s year=%s value=%s",
        table,
        asset,
        year,
        value,
    )

    # --- Persist to database ---
    # Replace the block below with a real SQLAlchemy write once the
    # equity_share table exists.
    #
    # Example:
    #   from superset import db
    #   db.session.execute(
    #       text(
    #           "UPDATE equity_share SET value = :v "
    #           "WHERE asset = :a AND year = :y AND tbl = :t"
    #       ),
    #       {"v": value, "a": asset, "y": year, "t": table},
    #   )
    #   db.session.commit()

    return (
        jsonify(
            {
                "status": "ok",
                "saved": {
                    "asset": asset,
                    "year": year,
                    "value": value,
                    "table": table,
                },
            }
        ),
        200,
    )


@scenario_bp.route("/health", methods=["GET"])
def health() -> Any:
    """Simple health check for the scenario blueprint."""
    return jsonify({"status": "ok", "blueprint": "scenario"}), 200
