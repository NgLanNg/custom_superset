import json

with open("chart_details.json") as f:
    charts = { c["id"]: c for c in json.load(f)}

pos = {
    "DASHBOARD_VERSION_KEY": "v2",
    "ROOT_ID": {"children": ["GRID_ID"], "id": "ROOT_ID", "type": "ROOT"},
    "GRID_ID": {"children": ["ROW-0", "ROW-1", "ROW-2", "ROW-3", "ROW-4"], "id": "GRID_ID", "parents": ["ROOT_ID"], "type": "GRID"},
    "HEADER_ID": {"id": "HEADER_ID", "meta": {"text": "OPU GHG Summary Sheet"}, "type": "HEADER"}
}

row_charts = [
    [4, 5],
    [6, 10],
    [7, 11],
    [8, 12],
    [9, 13]
]

for r_idx, chart_ids in enumerate(row_charts):
    row_id = f"ROW-{r_idx}"
    pos[row_id] = {
        "children": [f"CHART-{cid}" for cid in chart_ids],
        "id": row_id,
        "meta": {"background": "BACKGROUND_TRANSPARENT"},
        "parents": ["ROOT_ID", "GRID_ID"],
        "type": "ROW"
    }
    for cid in chart_ids:
        chart = charts[cid]
        pos[f"CHART-{cid}"] = {
            "children": [],
            "id": f"CHART-{cid}",
            "meta": {
                "chartId": cid,
                "height": 50,
                "sliceName": chart["slice_name"],
                "uuid": chart["uuid"],
                "width": 6
            },
            "parents": ["ROOT_ID", "GRID_ID", row_id],
            "type": "CHART"
        }

print(json.dumps(pos))
