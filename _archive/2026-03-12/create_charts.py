import requests
import json

base_url = "http://localhost:8088"
with open("login_res.json") as f:
    token = json.load(f)["access_token"]

# Get CSRF
csrf_res = requests.get(f"{base_url}/api/v1/security/csrf_token/", headers={"Authorization": f"Bearer {token}"})
csrf_token = csrf_res.json()["result"]

headers = {
    "Authorization": f"Bearer {token}",
    "X-CSRFToken": csrf_token,
    "Content-Type": "application/json"
}

cookies = requests.utils.cookiejar_from_dict({
    "session": requests.Session().get(f"{base_url}/api/v1/security/csrf_token/", headers={"Authorization": f"Bearer {token}"}).cookies.get("session")
})
# Actually it's easier to just use the cookies from file
import http.cookiejar
cj = http.cookiejar.MozillaCookieJar('cookies.txt')
cj.load(ignore_discard=True, ignore_expires=True)
session = requests.Session()
session.cookies = cj

def create_chart(name, viz_type, datasource_id, params):
    payload = {
        "slice_name": name,
        "viz_type": viz_type,
        "datasource_id": datasource_id,
        "datasource_type": "table",
        "params": json.dumps(params)
    }
    res = session.post(f"{base_url}/api/v1/chart/", headers=headers, json=payload)
    if res.status_code == 201:
        print(f"Created {name}: ID {res.json()['id']}")
        return res.json()["id"]
    else:
        print(f"Failed to create {name}: {res.text}")
        return None

# T6
c1_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "groupby": ["year"],
    "columns": ["type", "kpi"],
    "adhoc_filters": [{"expressionType": "SIMPLE", "subject": "kpi", "operator": "IN", "comparator": ["OC", "ES"], "clause": "WHERE"}],
    "row_limit": 1000,
    "viz_type": "dist_bar"
}
# Since I already created C1 with ID 4, I'll update it or just create a new one and delete 4 later.
# Actually I'll create new ones with correct names.

c1_id = create_chart("C1 — GHG Reduction OC/ES", "dist_bar", 3, c1_params)

c2_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "groupby": ["year"],
    "columns": ["type"],
    "adhoc_filters": [{"expressionType": "SIMPLE", "subject": "kpi", "operator": "==", "comparator": "CAPEX", "clause": "WHERE"}],
    "row_limit": 1000,
    "viz_type": "dist_bar",
    "y_axis_label": "RM Million"
}
c2_id = create_chart("C2 — Green CAPEX", "dist_bar", 3, c2_params)

# T7 - Left Panel (OC)
c3_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "groupby": ["metric"],
    "x_axis": "year",
    "adhoc_filters": [
        {"expressionType": "SIMPLE", "subject": "category", "operator": "==", "comparator": "GHG Intensity", "clause": "WHERE"},
        {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "operational control", "clause": "WHERE"}
    ],
    "viz_type": "echarts_area"
}
c3_id = create_chart("C3 — OC GHG Intensity", "echarts_area", 2, c3_params)

c4_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "x_axis": "year",
    "adhoc_filters": [
        {"expressionType": "SIMPLE", "subject": "metric", "operator": "==", "comparator": "Total GHG Emission", "clause": "WHERE"},
        {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "operational control", "clause": "WHERE"}
    ],
    "viz_type": "echarts_timeseries_line"
}
c4_id = create_chart("C4 — OC Total GHG Emission", "echarts_timeseries_line", 2, c4_params)

c5_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "x_axis": "year",
    "adhoc_filters": [
        {"expressionType": "SIMPLE", "subject": "metric", "operator": "==", "comparator": "Upon Reduction", "clause": "WHERE"},
        {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "operational control", "clause": "WHERE"}
    ],
    "viz_type": "echarts_timeseries_line"
}
c5_id = create_chart("C5 — OC Upon Reduction", "echarts_timeseries_line", 2, c5_params)

c6_params = {
    "metrics": [{"expressionType": "SIMPLE", "column": {"column_name": "value"}, "aggregate": "SUM", "label": "SUM(value)"}],
    "groupby": ["metric", "year", "uom"],
    "adhoc_filters": [
        {"expressionType": "SIMPLE", "subject": "category", "operator": "==", "comparator": "Production", "clause": "WHERE"},
        {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "operational control", "clause": "WHERE"}
    ],
    "viz_type": "table"
}
c6_id = create_chart("C6 — OC Production", "table", 2, c6_params)

# T8 - Right Panel (ES)
c7_params = c3_params.copy()
c7_params["adhoc_filters"] = [
    {"expressionType": "SIMPLE", "subject": "category", "operator": "==", "comparator": "GHG Intensity", "clause": "WHERE"},
    {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "equity share", "clause": "WHERE"}
]
c7_id = create_chart("C7 — ES GHG Intensity", "echarts_area", 2, c7_params)

c8_params = c4_params.copy()
c8_params["adhoc_filters"] = [
    {"expressionType": "SIMPLE", "subject": "metric", "operator": "==", "comparator": "Total GHG Emission", "clause": "WHERE"},
    {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "equity share", "clause": "WHERE"}
]
c8_id = create_chart("C8 — ES Total GHG Emission", "echarts_timeseries_line", 2, c8_params)

c9_params = c5_params.copy()
c9_params["adhoc_filters"] = [
    {"expressionType": "SIMPLE", "subject": "metric", "operator": "==", "comparator": "Upon Reduction", "clause": "WHERE"},
    {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "equity share", "clause": "WHERE"}
]
c9_id = create_chart("C9 — ES Upon Reduction", "echarts_timeseries_line", 2, c9_params)

c10_params = c6_params.copy()
c10_params["adhoc_filters"] = [
    {"expressionType": "SIMPLE", "subject": "category", "operator": "==", "comparator": "Production", "clause": "WHERE"},
    {"expressionType": "SIMPLE", "subject": "type", "operator": "==", "comparator": "equity share", "clause": "WHERE"}
]
c10_id = create_chart("C10 — ES Production", "table", 2, c10_params)

