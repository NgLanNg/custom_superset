# Step 01: Scan for Redundant Files

**Purpose:** Locate all files that are not part of the core project structure.

## Instructions

1. Scan the root directory for:
   - `.tmp`, `.tmp.*`, `temp_*`, `debug_*` files
   - `output.txt`, `result.log`, `*.cache` files
   - `_old`, `_backup`, `_prev` files
2. Search `/tmp` for temporary files
3. Identify log files in `./logs/` or `.agents/logs/`
4. List backup files (`*.bak`, `*.old`, etc.)

## Output

- `redundant_files`: Files not part of core structure
- `temp_files`: Temporary or debug files
- `log_files`: Log files to consolidate
- `backup_files`: Backup copies to archive

## Ready to Continue?

- [C] Continue to Step 02: Categorize Artifacts
- [A] Adjust: Expand search scope
- [P] Pause: Wait for user instruction
