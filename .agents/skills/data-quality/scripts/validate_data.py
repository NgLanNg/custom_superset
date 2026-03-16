#!/usr/bin/env python3
"""
Data quality validator: run checks against CSV/Parquet and emit validation report.
Usage: python3 validate_data.py <data_file> <rules_file>
"""

import sys
import csv
from pathlib import Path

def load_rules(rules_file):
 """Load validation rules from YAML/JSON"""
 rules = {}
 try:
 import yaml
 with open(rules_file, 'r') as f:
 rules = yaml.safe_load(f)
 except ImportError:
 print("ERROR: PyYAML required. Install: pip install pyyaml")
 sys.exit(1)
 return rules

def validate_csv(data_file, rules):
 """Run validations on CSV file"""
 errors = []
 stats = {
 'total_rows': 0,
 'null_counts': {},
 'duplicate_keys': {},
 'out_of_range': {}
 }
 
 with open(data_file, 'r') as f:
 reader = csv.DictReader(f)
 rows = list(reader)
 stats['total_rows'] = len(rows)
 
 # Check not_null
 if 'not_null' in rules:
 for col in rules['not_null']:
 null_count = sum(1 for r in rows if not r.get(col) or r.get(col).strip() == '')
 stats['null_counts'][col] = null_count
 if null_count > 0:
 errors.append(f"WARN: Column '{col}' has {null_count} nulls")
 
 # Check uniqueness
 if 'unique' in rules:
 for col in rules['unique']:
 seen = set()
 dupes = 0
 for r in rows:
 val = r.get(col)
 if val in seen:
 dupes += 1
 seen.add(val)
 stats['duplicate_keys'][col] = dupes
 if dupes > 0:
 errors.append(f"ERROR: Column '{col}' has {dupes} duplicates")
 
 # Check range constraints
 if 'range' in rules:
 for col, (min_val, max_val) in rules['range'].items():
 out_of_range = 0
 for r in rows:
 try:
 val = float(r.get(col, 0))
 if val < min_val or val > max_val:
 out_of_range += 1
 except ValueError:
 out_of_range += 1
 stats['out_of_range'][col] = out_of_range
 if out_of_range > 0:
 errors.append(f"WARN: Column '{col}' has {out_of_range} out-of-range values")
 
 return errors, stats

if __name__ == '__main__':
 if len(sys.argv) < 2:
 print("Usage: python3 validate_data.py <data_file.csv> <rules.yaml>")
 print("\nExample rules.yaml:")
 print(" not_null: [customer_id, email]")
 print(" unique: [customer_id]")
 print(" range:")
 print(" age: [0, 150]")
 sys.exit(1)
 
 data_file = sys.argv[1]
 rules_file = sys.argv[2] if len(sys.argv) > 2 else 'validation_rules.yaml'
 
 if not Path(data_file).exists():
 print(f"ERROR: Data file '{data_file}' not found")
 sys.exit(1)
 
 rules = load_rules(rules_file) if Path(rules_file).exists() else {}
 
 print(f"Validating {data_file}...")
 errors, stats = validate_csv(data_file, rules)
 
 print(f"\n=== Results ===")
 print(f"Total rows: {stats['total_rows']}")
 print(f"Issues found: {len(errors)}")
 for err in errors:
 print(f" {err}")
 
 if len(errors) == 0:
 print("✓ All validations passed")
