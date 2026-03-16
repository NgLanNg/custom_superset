## Core Workflow 
1. Session Start: Load {{vault/active_context.md}}, check {{.agents/roles/}}, {{.agents/skills/}}, {{MCP}}; use {{claude/gemini}} subagents for parallel work
2. Pre-Task: Research first → Plan Mode (if 3 steps) → update {{vault/tasks/todo_{brief}_{date}.md}}
3. Execution ({{NYQUIST}}): Declare task order/files → sequential execution → test each → mark {{[x]}} on pass
4. Verification: Show proof (diffs/logs) → no hacks → full test suite (no simpler shortcuts)
5. Safety: 3 strikes → escalate → archive to {{_archive/}} (no {{rm}}) → no secrets → update context
6. Principles: Simplicity first → root causes → minimal impact → full rigor only
7. Subagents: Brief + context links → narrow scope → update {{vault/tasks/todo_{brief}_{date}.md}} + report