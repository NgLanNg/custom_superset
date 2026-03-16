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
from flask_login import LoginManager, UserMixin
import pytest

from superset.views.scenario_writeback import ScenarioWritebackView


class _MockUser(UserMixin):
    """Minimal authenticated user for unit tests."""
    id = "1"
    email = "test@example.com"


@pytest.fixture
def client():
    app = Flask(__name__)
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['SECRET_KEY'] = 'test-secret'

    login_manager = LoginManager()
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(_user_id: str):  # noqa: ANN202
        return _MockUser()

    # Register the view directly for testing
    view = ScenarioWritebackView()
    # Mocking the appbuilder attachment
    view.appbuilder = MagicMock()
    
    # Simple explicit registration without using appbuilder's complex machinery
    @app.route("/api/v1/scenario/writeback", methods=["POST"])
    def writeback():
        return view.writeback()

    @app.route("/api/v1/scenario/health", methods=["GET"])
    def health():
        return view.health()
    
    with app.test_client() as client:
        # Seed session so @login_required passes
        with client.session_transaction() as sess:
            sess['_user_id'] = '1'
            sess['_fresh'] = True
        yield client

def test_health_endpoint(client):
    resp = client.get("/api/v1/scenario/health")
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data["status"] == "ok"
    assert data["view"] == "scenario"

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

def test_writeback_oversized_payload(client):
    payload = {
        "scenario_name": "A" * 200, # Too long
        "bu": "B",
        "opu": "C",
        "year": 2025,
        "value": 50
    }
    resp = client.post("/api/v1/scenario/writeback", json=payload)
    assert resp.status_code == 400
    data = json.loads(resp.data)
    assert "exceeds max length" in data["message"]

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
    
    # BaseSupersetView's json_response might structure JSON differently 
    # but we check if result contains what we expect
    assert data["status"] == "success"
    
    # Verify execute was called with correct SQL
    args, kwargs = mock_db.session.execute.call_args
    stmt = str(args[0])
    params = args[1]
    
    assert "ON CONFLICT" in stmt
    assert "DO UPDATE SET" in stmt
    assert params["scen"] == "Base"
    assert params["bu"] == "Test BU"
    assert params["val"] == 45.5
    assert params["sid"] == "scen-id-123"
    
    mock_db.session.commit.assert_called_once()

@patch("superset.views.scenario_writeback.db")
def test_writeback_exception(mock_db, client):
    mock_db.session.execute.side_effect = Exception("DB Error Detail")
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
    
    data = json.loads(resp.data)
    assert "Database write failed" in data["message"]
    
    mock_db.session.rollback.assert_called_once()
