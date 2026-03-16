#!/usr/bin/env python3
import os
import glob
import re

ROLES_DIR = ".agents/roles/sub"
CLAUDE_DIR = ".claude/agents"
GEMINI_DIR = ".gemini/agents"

def ensure_dir(d):
    if not os.path.exists(d):
        os.makedirs(d)

def clean_slug(filename):
    # e.g., behavioral_psychologist.yaml -> behavioral-psychologist
    base = os.path.basename(filename).replace(".yaml", "")
    return re.sub(r'[^a-zA-Z0-9]', '-', base).lower()

def extract_title(content, fallback):
    match = re.search(r'title:\s*(.+)', content)
    if match:
        return match.group(1).strip().strip("'\"")
    return fallback.replace('-', ' ').title()

def main():
    ensure_dir(CLAUDE_DIR)
    ensure_dir(GEMINI_DIR)

    # find all yaml files in ROLES_DIR
    yaml_files = glob.glob(f"{ROLES_DIR}/**/*.yaml", recursive=True)
    
    count = 0
    for path in yaml_files:
        # Ignore template
        if "_TEMPLATE.yaml" in path:
            continue
            
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        slug = clean_slug(path)
        title = extract_title(content, slug)
        
        # Build Claude Agent MD
        claude_md = f"""---
name: "{slug}"
description: "{title} specialist. Delegates to this persona for complex reasoning, logic, and formatting."
model: sonnet
tools: ["Read", "Grep", "Glob", "Bash", "LS"]
---
You are a dynamic specialist. Internalize the following persona definition and act strictly according to its principles and identity:

```yaml
{content}
```
"""

        # Build Gemini Agent MD
        gemini_md = f"""---
name: "{slug}"
description: "{title} specialist. Delegates to this persona for massive context investigation and bulk screening."
kind: local
tools:
  - read_file
  - write_file
  - replace_in_file
  - grep_search
  - find_files
  - run_shell_command
  - list_directory
model: gemini-2.5-pro
max_turns: 15
---
You are a dynamic specialist. Internalize the following persona definition and act strictly according to its principles and identity:

```yaml
{content}
```
"""

        # Write Claude
        claude_path = os.path.join(CLAUDE_DIR, f"{slug}.md")
        with open(claude_path, 'w', encoding='utf-8') as f:
            f.write(claude_md)
            
        # Write Gemini
        gemini_path = os.path.join(GEMINI_DIR, f"{slug}.md")
        with open(gemini_path, 'w', encoding='utf-8') as f:
            f.write(gemini_md)
            
        count += 1
        
    print(f"Successfully synced {count} subagents to {CLAUDE_DIR} and {GEMINI_DIR}.")

if __name__ == "__main__":
    # Ensure run from project root
    if not os.path.exists(".agents"):
        print("Error: Must be run from the project root containing .agents/")
        exit(1)
    main()
