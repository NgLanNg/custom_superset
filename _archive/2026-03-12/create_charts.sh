#!/bin/bash
TOKEN=$(python3 -c "import sys,json; print(json.load(open('login_res.json'))['access_token'])")
CSRF_TOKEN=$(curl -s -X GET http://localhost:8088/api/v1/security/csrf_token/ -H "Authorization: Bearer $TOKEN" -b cookies.txt | python3 -c "import sys,json; print(json.load(sys.stdin)['result'])")

create_chart() {
    NAME=$1
    VIZ_TYPE=$2
    DS_ID=$3
    PARAMS=$4
    
    curl -s -X POST http://localhost:8088/api/v1/chart/ \
      -H "Authorization: Bearer $TOKEN" \
      -H "X-CSRFToken: $CSRF_TOKEN" \
      -H "Content-Type: application/json" \
      -b cookies.txt \
      -d "{
        \"slice_name\": \"$NAME\",
        \"viz_type\": \"$VIZ_TYPE\",
        \"datasource_id\": $DS_ID,
        \"datasource_type\": \"table\",
        \"params\": $PARAMS
      }" | python3 -c "import sys,json; res=json.load(sys.stdin); print(f'Created {res.get(\"result\",{}).get(\"slice_name\", \"Unknown\")}: ID {res.get(\"id\", \"Error\")}')"
}

# C2
PARAMS_C2=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'groupby': ['year'],
    'columns': ['type'],
    'adhoc_filters': [{'expressionType': 'SIMPLE', 'subject': 'kpi', 'operator': '==', 'comparator': 'CAPEX', 'clause': 'WHERE'}],
    'row_limit': 1000,
    'viz_type': 'dist_bar',
    'y_axis_label': 'RM Million'
})))")
create_chart "C2 — Green CAPEX" "dist_bar" 3 "$PARAMS_C2"

# C3
PARAMS_C3=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'groupby': ['metric'],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'category', 'operator': '==', 'comparator': 'GHG Intensity', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'operational control', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_area'
})))")
create_chart "C3 — OC GHG Intensity" "echarts_area" 2 "$PARAMS_C3"

# C4
PARAMS_C4=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'metric', 'operator': '==', 'comparator': 'Total GHG Emission', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'operational control', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_timeseries_line'
})))")
create_chart "C4 — OC Total GHG Emission" "echarts_timeseries_line" 2 "$PARAMS_C4"

# C5
PARAMS_C5=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'metric', 'operator': '==', 'comparator': 'Upon Reduction', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'operational control', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_timeseries_line'
})))")
create_chart "C5 — OC Upon Reduction" "echarts_timeseries_line" 2 "$PARAMS_C5"

# C6
PARAMS_C6=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'groupby': ['metric', 'year', 'uom'],
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'category', 'operator': '==', 'comparator': 'Production', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'operational control', 'clause': 'WHERE'}
    ],
    'viz_type': 'table'
})))")
create_chart "C6 — OC Production" "table" 2 "$PARAMS_C6"

# Right Panel (ES)
PARAMS_C7=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'groupby': ['metric'],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'category', 'operator': '==', 'comparator': 'GHG Intensity', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'equity share', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_area'
})))")
create_chart "C7 — ES GHG Intensity" "echarts_area" 2 "$PARAMS_C7"

PARAMS_C8=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'metric', 'operator': '==', 'comparator': 'Total GHG Emission', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'equity share', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_timeseries_line'
})))")
create_chart "C8 — ES Total GHG Emission" "echarts_timeseries_line" 2 "$PARAMS_C8"

PARAMS_C9=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'x_axis': 'year',
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'metric', 'operator': '==', 'comparator': 'Upon Reduction', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'equity share', 'clause': 'WHERE'}
    ],
    'viz_type': 'echarts_timeseries_line'
})))")
create_chart "C9 — ES Upon Reduction" "echarts_timeseries_line" 2 "$PARAMS_C9"

PARAMS_C10=$(python3 -c "import json; print(json.dumps(json.dumps({
    'metrics': [{'expressionType': 'SIMPLE', 'column': {'column_name': 'value'}, 'aggregate': 'SUM', 'label': 'SUM(value)'}],
    'groupby': ['metric', 'year', 'uom'],
    'adhoc_filters': [
        {'expressionType': 'SIMPLE', 'subject': 'category', 'operator': '==', 'comparator': 'Production', 'clause': 'WHERE'},
        {'expressionType': 'SIMPLE', 'subject': 'type', 'operator': '==', 'comparator': 'equity share', 'clause': 'WHERE'}
    ],
    'viz_type': 'table'
})))")
create_chart "C10 — ES Production" "table" 2 "$PARAMS_C10"

