"""
Custom View for Scenario OPU Config
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


class OPUConfigView(BaseSupersetView):
    route_base = "/api/v1/scenario/opu-config"

    @has_access_api
    @expose("", methods=("GET",))
    def get_config(self) -> Any:
        """
        Fetch OPU configuration data for a scenario.
        """
        scenario_name = request.args.get("scenario_name", "existing_assets")
        
        stmt = text(
            """
            SELECT id, opu, bu, type, base_equity_pct, region, active, updated_at
            FROM silver_scenario_opu_config
            WHERE scenario_name = :scen
            ORDER BY type, opu;
            """
        )
        
        try:
            result = db.session.execute(stmt, {"scen": scenario_name})
            rows = [dict(r._mapping) for r in result]
            
            # Format dates to string
            for row in rows:
                if row.get('updated_at'):
                    row['updated_at'] = row['updated_at'].isoformat()
                # Ensure equity is float before sending to UI
                row['base_equity_pct'] = float(row['base_equity_pct'] or 0)
                # Ensure active is boolean
                row['active'] = bool(row['active'])
                    
            return self.json_response({
                "status": "success",
                "data": rows
            })
        except Exception as e:
            logger.error("Failed to fetch OPU config: %s", e, exc_info=True)
            return jsonify(
                {"status": "error", "message": f"Database read failed: {str(e)}"}
            ), 500

    @has_access_api
    @expose("", methods=("POST",))
    def save_config(self) -> Any:
        """
        Receive a cell edit from the OPU Config UI and persist it.
        """
        payload: dict[str, Any] = request.get_json(silent=True, force=True) or {}

        required = ["scenario_name", "opu"]
        for field in required:
            if field not in payload:
                return jsonify(
                    {"status": "error", "message": f"Missing field: {field}"}
                ), 400

        # Length validation on text fields
        for text_field in ("scenario_name", "opu", "bu", "type", "region"):
            val = payload.get(text_field)
            if val is not None:
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
            base_equity_pct = float(payload.get("base_equity_pct", 0)) if payload.get("base_equity_pct") is not None else None
            if base_equity_pct is not None and not (0 <= base_equity_pct <= 100):
                return jsonify({"status": "error", "message": "base_equity_pct must be between 0 and 100"}), 400
                
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
            INSERT INTO silver_scenario_opu_config (
                id, scenario_name, opu, bu, type, base_equity_pct, region, active, user_email, updated_at
            ) VALUES (
                :id, :scen, :opu, :bu, :type, :pct, :region, :active, :email, :ts
            )
            ON CONFLICT(scenario_name, opu, user_email)
            DO UPDATE SET
                bu = COALESCE(excluded.bu, silver_scenario_opu_config.bu),
                type = COALESCE(excluded.type, silver_scenario_opu_config.type),
                base_equity_pct = COALESCE(excluded.base_equity_pct, silver_scenario_opu_config.base_equity_pct),
                region = COALESCE(excluded.region, silver_scenario_opu_config.region),
                active = COALESCE(excluded.active, silver_scenario_opu_config.active),
                updated_at = excluded.updated_at;
            """
        )

        try:
            db.session.execute(
                stmt,
                {
                    "id": str(uuid.uuid4()),
                    "scen": payload["scenario_name"],
                    "opu": payload["opu"],
                    "bu": payload.get("bu") or "LNGA",
                    "type": payload.get("type") or "existing",
                    "pct": base_equity_pct,
                    "region": payload.get("region") or "",
                    "active": payload.get("active", True),
                    "email": user_email,
                    "ts": datetime.now(timezone.utc),
                },
            )
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logger.error("Failed to upsert OPU config data: %s", e, exc_info=True)
            return jsonify(
                {"status": "error", "message": f"Database write failed: {str(e)}"}
            ), 500

        return self.json_response(
            {
                "status": "success",
                "data": {
                    "opu": payload["opu"],
                },
            }
        )
