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

import json
from unittest.mock import patch, MagicMock
from flask import Flask
import pytest
from superset.views.scenario_writeback import scenario_bp

@pytest.fixture
def client():
    app = Flask(__name__)
    app.config['TESTING'] = True
    app.register_blueprint(scenario_bp, url_prefix='/api/v1/scenario')
    
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    resp = client.get("/api/v1/scenario/health")
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data["status"] == "ok"
    assert data["blueprint"] == "scenario"

def test_writeback_missing_fields(client):
    resp = client.post("/api/v1/scenario/writeback", json={"scenario_name": "Test"})
    assert resp.status_code == 400
    data = json.loads(resp.data)
    assert "Missing field:" in data["message"]

def test_writeback_invalid_value(client):
    payload = {
        "scenario_name": "Base",
        "bu": "Test BU",
        "opu": "Test OPU",
        "year": 2025,
        "value": 150 # Invalid
    }
    resp = client.post("/api/v1/scenario/writeback", json=payload)
    assert resp.status_code == 400
    data = json.loads(resp.data)
    assert "between 0 and 100" in data["message"]

@patch("superset.views.scenario_writeback.db")
def test_writeback_success(mock_db, client):
    payload = {
        "scenario_name": "Base",
        "bu": "Test BU",
        "opu": "Test OPU",
        "year": 2025,
        "value": 45.5,
        "scenario_id": "scen-id-123"
    }
    resp = client.post("/api/v1/scenario/writeback", json=payload)
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data["status"] == "success"
    
    mock_db.session.execute.assert_called_once()
    mock_db.session.commit.assert_called_once()

@patch("superset.views.scenario_writeback.db")
def test_writeback_exception(mock_db, client):
    mock_db.session.execute.side_effect = Exception("DB Error")
    payload = {
        "scenario_name": "Base2",
        "bu": "Test BU",
        "opu": "Test OPU",
        "year": 2025,
        "value": 45.5,
        "scenario_id": "scen-id-123"
    }
    resp = client.post("/api/v1/scenario/writeback", json=payload)
    assert resp.status_code == 500
    
    mock_db.session.rollback.assert_called_once()

