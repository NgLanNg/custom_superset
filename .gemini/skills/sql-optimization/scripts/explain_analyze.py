#!/usr/bin/env python3
"""
SQL query analyzer: extract slow queries from logs and suggest optimizations.
Usage: python3 explain_analyze.py <query.sql> <dialect: postgres|snowflake|bigquery>
"""

import sys
import re

def suggest_optimizations(sql_text):
 """Scan SQL for common anti-patterns"""
 suggestions = []
 
 if 'SELECT *' in sql_text.upper():
 suggestions.append("WARN: SELECT * - specify only needed columns")
 
 if sql_text.upper().count('SELECT') > 2:
 suggestions.append("INFO: Multiple subqueries - consider refactoring with CTEs")
 
 if re.search(r'SELECT.*\(SELECT.*FROM.*WHERE.*=.*\)', sql_text, re.IGNORECASE):
 suggestions.append("WARN: Correlated subquery - use JOIN or window function instead")
 
 if 'NOT IN (SELECT' in sql_text.upper():
 suggestions.append("WARN: NOT IN with subquery - use NOT EXISTS (NULLs can cause issues)")
 
 if 'GROUP BY' in sql_text.upper() and 'HAVING' not in sql_text.upper():
 suggestions.append("TIP: GROUP BY without HAVING - consider adding filter after aggregation")
 
 if 'DISTINCT' in sql_text.upper() and 'GROUP BY' in sql_text.upper():
 suggestions.append("WARN: DISTINCT + GROUP BY - redundant, remove DISTINCT")
 
 if re.search(r'LIKE\s+[\'"][%]', sql_text, re.IGNORECASE):
 suggestions.append("WARN: LIKE '%pattern' - leading wildcard prevents index use")
 
 if 'JOIN' in sql_text.upper() and 'ON' not in sql_text.upper():
 suggestions.append("ERROR: JOIN without ON - cartesian product risk")
 
 return suggestions

def format_explain_template(dialect):
 """Show EXPLAIN ANALYZE template for dialect"""
 templates = {
 'postgres': """
-- PostgreSQL EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT ... FROM ... WHERE ...;

-- Read output:
-- - Seq Scan = full table scan (consider INDEX)
-- - Actual Time > Planned Time = inaccurate stats (run ANALYZE table)
-- - Buffers: shared hit = cache, disk read = slow
""",
 'snowflake': """
-- Snowflake PROFILE
SET TIMING = ON;
PROFILE
SELECT ... FROM ... WHERE ...;

-- Check:
-- - Scanned Bytes > Selected Bytes = pruning inefficient
-- - Compilation Time > Execution Time = complex query
""",
 'bigquery': """
-- BigQuery EXPLAIN
EXPLAIN SELECT ... FROM ... WHERE ...;

-- Check:
-- - CPU ms > memory ms = compute-bound (add index/partition)
-- - Shuffle bytes = expensive (avoid large JOINs on non-clustered keys)
"""
 }
 return templates.get(dialect, "Unknown dialect")

if __name__ == '__main__':
 if len(sys.argv) < 2:
 print("Usage: python3 explain_analyze.py <query.sql> [postgres|snowflake|bigquery]")
 sys.exit(1)
 
 try:
 with open(sys.argv[1], 'r') as f:
 query = f.read()
 except FileNotFoundError:
 print(f"Error: File {sys.argv[1]} not found")
 sys.exit(1)
 
 print("=== Query Suggestions ===")
 suggestions = suggest_optimizations(query)
 for s in suggestions:
 print(f" {s}")
 
 dialect = sys.argv[2] if len(sys.argv) > 2 else 'postgres'
 print(f"\n=== {dialect.upper()} EXPLAIN Template ===")
 print(format_explain_template(dialect))
