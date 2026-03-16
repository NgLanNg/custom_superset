#!/usr/bin/env python3
"""
dbt test generator: scaffold generic and custom test files from model columns.
Usage: python3 generate_tests.py <model_name> <column_list>
Example: python3 generate_tests.py fct_orders "order_id,customer_id,status"
"""

import sys
import yaml

def generate_yaml_tests(model_name, columns):
 """Generate YAML test block for dbt schema.yml"""
 columns_list = columns.split(',')
 yaml_block = {
 'models': [
 {
 'name': model_name,
 'columns': []
 }
 ]
 }
 
 for col in columns_list:
 col = col.strip()
 col_config = {'name': col, 'tests': ['not_null', 'unique']}
 yaml_block['models'][0]['columns'].append(col_config)
 
 print("# Add to dbt/models/schema.yml")
 print(yaml.dump(yaml_block, default_flow_style=False))

def generate_custom_test(model_name, column_name):
 """Generate skeleton custom SQL test"""
 test_name = f"assert_{model_name}_{column_name}_valid"
 sql = f"""-- tests/{test_name}.sql
select *
from {{{{ ref('{model_name}') }}}}
where {column_name} is null or {column_name} = ''
-- Add validation logic here
"""
 print(sql)

if __name__ == '__main__':
 if len(sys.argv) < 2:
 print("Usage: python3 generate_tests.py <model_name> <column_list>")
 sys.exit(1)
 
 model = sys.argv[1]
 cols = sys.argv[2] if len(sys.argv) > 2 else "id,created_at"
 generate_yaml_tests(model, cols)
