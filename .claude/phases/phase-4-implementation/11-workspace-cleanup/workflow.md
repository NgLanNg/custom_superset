# Workflow: Workspace Cleanup

**Phase:** 4 — Implementation
**Config:** `config.yaml`
**Primary Role:** Dev

## Purpose

Maintain workspace hygiene by archiving redundant files and updating active context.

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `identify_clutter`.

### Flow Steps

1. **Scan** - Locate all redundant, temp, log, and backup files
2. **Categorize** - Group files by type for appropriate archival
3. **Archive** - Move files to date-based archive folder
4. **Log Rotation** - Consolidate or archive large log files
5. **Prune Context** - Review and update `vault/active_context.md`
6. **Report** - Generate hygiene report for the session

### Checkpoints (Human-in-Loop)

- After scan - validate clutter identification
- After categorization - validate artifact groups
- After archival - validate archive operation
- After log rotation - validate cleanup
- After context pruning - validate updates
- Final confirmation - complete cleanup

## Rules

- **No Data Loss** - Archive everything before deleting
- **Signal Over Noise** - Clean repo leads to better reasoning
- **Predictable Structure** - Always use date-based archive folders
- **Never rm** - Always archive first, then delete
- At every checkpoint - STOP and wait for user confirmation

## Output

- `_archive/YYYY-MM-DD/` - Archived artifacts
- `vault/reports/YYYY-MM-DD-hygiene-report.md` - Hygiene report
- Updated `vault/active_context.md`

## End State

- Workspace clutter archived
- Log files consolidated
- Active context updated
- Hygiene report generated
