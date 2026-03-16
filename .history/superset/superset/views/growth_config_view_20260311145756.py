"""
Custom View for Scenario Growth Config
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

# Field length limits
_MAX_FIELD_LEN = 128


class GrowthConfigView(BaseSupersetView):
    route_base = "/api/v1/scenario/growth-config"

    @has_access_api
    @expose("", methods=("GET",))
    def get_config(self) -> Any:
        """
        Fetch growth configuration data for a scenario.
        """
        scenario_name = request.args.get("scenario_name", "existing_assets")
        
        stmt = text(
            """
            SELECT id, bu, project, fid_year, capacity_mtpa, capex_billion, status, updated_at
            FROM silver_scenario_growth_config
            WHERE scenario_name = :scen
            ORDER BY project;
            """
        )
        
        try:
            result = db.session.execute(stmt, {"scen": scenario_name})
            rows = [dict(r._mapping) for r in result]
            
            # Format dates to string
            for row in rows:
                if row.get('updated_at'):
                    row['updated_at'] = row['updated_at'].isoformat()
                # Ensure capacity and capex are floats before sending to UI
                row['capacity_mtpa'] = float(row['capacity_mtpa'] or 0)
                row['capex_billion'] = float(row['capex_billion'] or 0)
                    
            return self.json_response({
                "status": "success",
                "data": rows
            })
        except Exception as e:
            logger.error("Failed to fetch growth config: %s", e, exc_info=True)
            return jsonify(
                {"status": "error", "message": f"Database read failed: {str(e)}"}
            ), 500

    @has_access_api
    @expose("", methods=("POST",))
    def save_config(self) -> Any:
        """
        Receive a cell edit from the Growth UI and persist it.
        """
        payload: dict[str, Any] = request.get_json(silent=True, force=True) or {}

        required = ["scenario_name", "bu", "project"]
        for field in required:
            if field not in payload:
                return jsonify(
                    {"status": "error", "message": f"Missing field: {field}"}
                ), 400

        # Length validation on text fields
        for text_field in ("scenario_name", "bu", "project"):
            val = payload.get(text_field, "")
            if not isinstance(val, str) or not val.strip():
                return jsonify(
                    {"status": "error", "message": f"{text_field} must be a non-empty string"}
                ), 400
            if len(val) > _MAX_FIELD_LEN:
                return jsonify(
                    {"status": "error", "message": f"{text_field} exceeds max length"}
                ), 400

        # Data type validation for numeric fields
        try:
            fid_year = int(payload.get("fid_year", 0)) if payload.get("fid_year") is not None else None
            if fid_year is not None and not (2020 <= fid_year <= 2040):
                return jsonify({"status": "error", "message": "fid_year must be between 2020 and 2040"}), 400
                
            capacity_mtpa = float(payload.get("capacity_mtpa", 0)) if payload.get("capacity_mtpa") is not None else None
            if capacity_mtpa is not None and not (0 <= capacity_mtpa <= 100):
                return jsonify({"status": "error", "message": "capacity_mtpa must be between 0 and 100"}), 400
                
            capex_billion = float(payload.get("capex_billion", 0)) if payload.get("capex_billion") is not None else None
            if capex_billion is not None and not (0 <= capex_billion <= 50):
                return jsonify({"status": "error", "message": "capex_billion must be between 0 and 50"}), 400
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": "Numeric fields require numbers"}), 400

        # Try to gather useful user info from context
        user_email = "anonymous@local"
        try:
            if hasattr(current_user, "email") and current_user.email:
                user_email = current_user.email
            elif hasattr(current_user, "username") and current_user.username:
                user_email = current_user.username
            elif hasattr(current_user, "id"):
                user_email = f"user_{current_user.id}"
        except Exception as ue:
            logger.warning(f"Could not resolve user info: {ue}")

        # SQLite compatible UPSERT (INSERT ... ON CONFLICT DO UPDATE)
        stmt = text(
            """
            INSERT INTO silver_scenario_growth_config (
                id, scenario_name, bu, project, fid_year, capacity_mtpa, capex_billion, status, user_email, updated_at
            ) VALUES (
                :id, :scen, :bu, :proj, :fid, :cap, :capex, :status, :email, :ts
            )
            ON CONFLICT(scenario_name, project, user_email)
            DO UPDATE SET
                fid_year = COALESCE(excluded.fid_year, silver_scenario_growth_config.fid_year),
                capacity_mtpa = COALESCE(excluded.capacity_mtpa, silver_scenario_growth_config.capacity_mtpa),
                capex_billion = COALESCE(excluded.capex_billion, silver_scenario_growth_config.capex_billion),
                status = COALESCE(excluded.status, silver_scenario_growth_config.status),
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
                    "proj": payload["project"],
                    "fid": fid_year,
                    "cap": capacity_mtpa,
                    "capex": capex_billion,
                    "status": payload.get("status") or "On Track",
                    "email": user_email,
                    "ts": datetime.now(timezone.utc),
                },
            )
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logger.error("Failed to upsert growth config data: %s", e, exc_info=True)
            return jsonify(
                {"status": "error", "message": f"Database write failed: {str(e)}"}
            ), 500

        return self.json_response(
            {
                "status": "success",
                "data": {
                    "project": payload["project"],
                },
            }
        )
