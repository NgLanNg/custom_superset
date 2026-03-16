# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Mock Version 2.0 (the
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

import json
from sqlalchemy import text
from superset import db
from tests.integration_tests.base_tests import SupersetTestCase


class TestScenarioWriteback(SupersetTestCase):
    """Integration tests for the /api/v1/scenario/ endpoints."""

    def setUp(self):
        super().setUp()
        # Make sure the table exists for testing within the test DB dialect
        db.session.execute(
            text(
                """
                CREATE TABLE IF NOT EXISTS silver_scenario_equity_share (
                    id VARCHAR(255) PRIMARY KEY,
                    scenario_name VARCHAR(255) NOT NULL,
                    bu VARCHAR(255) NOT NULL,
                    opu VARCHAR(255) NOT NULL,
                    year INTEGER NOT NULL,
                    value REAL NOT NULL,
                    scenario_id VARCHAR(255),
                    user_email VARCHAR(255),
                    updated_at TIMESTAMP,
                    file_path VARCHAR(255),
                    UNIQUE(scenario_name, opu, year, scenario_id, user_email)
                );
                """
            )
        )
        db.session.commit()

    def tearDown(self):
        db.session.execute(text("DELETE FROM silver_scenario_equity_share"))
        db.session.commit()
        super().tearDown()

    def test_health_endpoint(self):
        resp = self.client.get("/api/v1/scenario/health")
        assert resp.status_code == 200
        data = json.loads(resp.data)
        assert data["status"] == "ok"
        assert data["blueprint"] == "scenario"

    def test_writeback_missing_fields(self):
        resp = self.client.post("/api/v1/scenario/writeback", json={"scenario_name": "Test"})
        assert resp.status_code == 400
        data = json.loads(resp.data)
        assert "Missing field:" in data["message"]

    def test_writeback_invalid_value(self):
        payload = {
            "scenario_name": "Base",
            "bu": "Test BU",
            "opu": "Test OPU",
            "year": 2025,
            "value": 150 # Invalid
        }
        resp = self.client.post("/api/v1/scenario/writeback", json=payload)
        assert resp.status_code == 400
        data = json.loads(resp.data)
        assert "between 0 and 100" in data["message"]

    def test_writeback_success(self):
        payload = {
            "scenario_name": "Base",
            "bu": "Test BU",
            "opu": "Test OPU",
            "year": 2025,
            "value": 45.5,
            "scenario_id": "scen-id-123"
        }
        resp = self.client.post("/api/v1/scenario/writeback", json=payload)
        assert resp.status_code == 200
        data = json.loads(resp.data)
        assert data["status"] == "success"
        
        result = db.session.execute(
            text("SELECT value FROM silver_scenario_equity_share WHERE scenario_name = 'Base'")
        ).fetchone()
        assert result is not None
        assert result[0] == 45.5

    def test_writeback_upsert(self):
        payload = {
            "scenario_name": "Base2",
            "bu": "Test BU",
            "opu": "Test OPU",
            "year": 2025,
            "value": 45.5,
            "scenario_id": "scen-id-123"
        }
        resp1 = self.client.post("/api/v1/scenario/writeback", json=payload)
        assert resp1.status_code == 200

        payload["value"] = 55.5
        resp2 = self.client.post("/api/v1/scenario/writeback", json=payload)
        assert resp2.status_code == 200
        
        result = db.session.execute(
            text("SELECT value FROM silver_scenario_equity_share WHERE scenario_name = 'Base2'")
        ).fetchone()
        assert result is not None
        assert result[0] == 55.5
