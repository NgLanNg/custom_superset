---
type: delegation-brief
date: {{ date }}
author: {{ author }}
project: {{ project_name }}
stepsCompleted: []
inputDocuments: []
---

# MISSION BRIEFING (Strict Contract)
>
> Sub-Agent Operations Protocol v2.5

## 1. Directive

**Task**: {{TASK_DESCRIPTION}}
**Status**: ACTIVE

## 2. Infrastructure Context

- **Target Files**: {{FILE_PATHS}}
- **Active Workflows**: [`likeaboss`, `test`, `audit`]
- **Core Rules**: `.agents/rules/RULES.md`

## 3. Pre-Operation: The "LikeABoss" Roundtable

Before any modifications, you MUST simulate a roundtable debate to handle engineering trade-offs.

**The Squad Recruitment (Internal Simulation):**
Select exactly **3-5 Personas** from the [Roles Registry](.agent/roles/INDEX.md) most relevant to this mission.

- Alice (Architect) - *Role from Engineering*
- Bob (Security) - *Role from Security*
- Charlie (Pragmatist) - *Role from Management*
- [Sub-Agent Choice 4]
- [Sub-Agent Choice 5]

**The Roundtable Protocol:**

1. **Debate**: Internally simulate a dialogue where these personas critique the task.
2. **Trade-offs**: Identify 2 key risks (Performance vs. Delivery, Security vs. UX).
3. **Consensus**: Agree on the single "High-Agency" path forward.

## 4. Operational Requirements

- **Test-First**: If logic changes, update/add tests using the `test` workflow.
- **RAG-First**: If context is missing, use `rag_search` to verify patterns.
- **Log Chronology Check**: EXPLICITLY verify `mcp_logs` to ensure RAG was performed before edits.
- **Invariants**: Do not break existing build or violate `.agent/rules/RULES.md`.

## 5. Completion Contract (MANDATORY JSON)

Your response MUST conclude with a technical block in the following format:

```json
{
 "status": "success" | "warning",
 "squad_consensus": "1-sentence summary of the roundtable conclusion",
 "files_modified": ["path/to/file1", "path/to/file2"],
 "tasks_completed": ["Sub-task A", "Sub-task B"],
 "rag_verified": Boolean (True if logs confirm 'context_manager' usage),
 "verification_done": "Method used to verify (e.g. pytest, manual run)",
 "next_lane_task": "Recommended next sub-agent task or command"
}
```
