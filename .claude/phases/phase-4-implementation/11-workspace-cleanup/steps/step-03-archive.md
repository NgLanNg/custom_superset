# Step 03: Archive Artifacts

**Purpose:** Move identified files to date-based archive folder.

## Instructions

1. Create `./_archive/YYYY-MM-DD/` folder
2. Move each category to its subfolder:
   - `./_archive/YYYY-MM-DD/temp/`
   - `./_archive/YYYY-MM-DD/output/`
   - `./_archive/YYYY-MM-DD/logs/`
   - `./_archive/YYYY-MM-DD/backups/`
3. Generate archive manifest

## Output

- `archive_path`: Path to the archive folder
- `archived_files_count`: Total number of files archived
- `archive_manifest`: List of moved files

## Ready to Continue?

- [C] Continue to Step 04: Log Rotation
- [A] Adjust: Review archived files
- [P] Pause: Wait for user instruction
