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

from superset.views.opu_config_view import OPUConfigView


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

    view = OPUConfigView()
    view.appbuilder = MagicMock()
    
    @app.route("/api/v1/scenario/opu-config", methods=["GET"])
    def get_config():
        return view.get_config()

    @app.route("/api/v1/scenario/opu-config", methods=["POST"])
    def save_config():
        return view.save_config()
    
    with app.test_client() as client:
        with client.session_transaction() as sess:
            sess['_user_id'] = '1'
            sess['_fresh'] = True
        yield client

def test_save_config_missing_fields(client):
    resp = client.post("/api/v1/scenario/opu-config", json={"scenario_name": "Test"})
    assert resp.status_code == 400
    data = json.loads(resp.data)
    assert "Missing field:" in data["message"]

def test_save_config_invalid_equity_pct(client):
    payload = {
        "scenario_name": "Base",
        "opu": "Opu 1",
        "base_equity_pct": 150
    }
    resp = client.post("/api/v1/scenario/opu-config", json=payload)
    assert resp.status_code == 400
    data = json.loads(resp.data)
    assert "must be between 0 and 100" in data["message"]

@patch("superset.views.opu_config_view.db")
def test_get_config_success(mock_db, client):
    # Mock row mapping
    row1 = MagicMock()
    row1._mapping = {"id": "uuid1", "opu": "opu1", "base_equity_pct": 50, "active": True, "updated_at": None}
    
    mock_result = [row1]
    mock_db.session.execute.return_value = mock_result
    
    resp = client.get("/api/v1/scenario/opu-config?scenario_name=Base")
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data["status"] == "success"
    assert len(data["data"]) == 1
    assert data["data"][0]["opu"] == "opu1"

@patch("superset.views.opu_config_view.db")
def test_save_config_success(mock_db, client):
    payload = {
        "scenario_name": "Base",
        "opu": "opu1",
        "bu": "LNGA",
        "type": "existing",
        "base_equity_pct": 65.5,
        "region": "Asia",
        "active": True
    }
    resp = client.post("/api/v1/scenario/opu-config", json=payload)
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data["status"] == "success"
    
    mock_db.session.execute.assert_called_once()
    mock_db.session.commit.assert_called_once()
    
    args, kwargs = mock_db.session.execute.call_args
    params = args[1]
    assert params["opu"] == "opu1"
    assert params["scen"] == "Base"
    assert params["pct"] == 65.5
