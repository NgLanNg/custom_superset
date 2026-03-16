---
description: Master entry point and session router. Bootstraps context and directs to the correct workflow.
---

# /start & /help

**Purpose: The single entry point router for all developer workflows. Automates project discovery, synchronizes session context, and suggests the next high-rigor action.**

**Scope:** `daily`
**Phase:** Multi-phase (Bootstrap & Routing)
**Deep Mode:** (Routing command - delegates to specific Phase workflows)

## When to Use

- At the beginning of every session (automatically triggered by BMAD rules).
- Whenever you start a new task or session.
- When you aren't sure which specific slash command to run or context feels stale.
- To avoid manual directory navigation for process discovery.

## Execution Path

> **Mandatory Session Bootstrapping & Routing**

1. **Context Loading**:
   - Always read `vault/active_context.md` and `vault/tasks/todo.md` first.
   - Verify environment variables and run quick health checks if applicable.
2. **Comprehensive Project Scan**: Perform a comprehensive scan of the codebase relevant to the current objective. For large repositories, use `repomix` or full directory loads.
3. **Phase Identification**: Determine the current lifecycle phase (1-4) based on the objective.
4. **Discipline Injection**:
   - If the task is complex, automatically break it down into **Epics and Stories**.
   - Inject **Discovery** and **Verification** gates into the `todo.md`.
5. **Role Adoption**: Check `.agents/roles/INDEX.md` and adopt the appropriate specialist role.
6. **Next Action**: State the exact workflow and mode being triggered (e.g., "Executing `/spec`").

## Output

- Fully grounded agent ready for rigorous execution.
- Immediate execution of the correct high-rigor workflow.

## Key Principles

- **Automatic by Default**: In BMAD, we don't wait for permission to start properly.
- **Context First**: Never act before reading the `vault`.
- **No Detective Work**: The agent finds the context; the user just provides the goal.
- **Rigor by Default**: Suggest the most disciplined path (e.g., `/spec` before `/code`).

---

## Phase Definitions

| Phase | Name | Commands | Purpose |
| :--- | :--- | :--- | :--- |
| **P1** | Analysis | `init`, `scan`, `research`, `brainstorm`, `audit`, `mcp`, `likeaboss` | Understand, discover, design |
| **P2** | Planning | `spec`, `todo` | Define scope, break down tasks |
| **P3** | Solutioning | `design-architect`, `tickets` | Architecture, epics/stories |
| **P4** | Implementation | `sprint`, `test`, `code`, `review`, `docs`, `clean`, `rethink` | Build, verify, deploy |

---

## Two Development Paths

| Path | Use Case | Complexity | Flow |
| :--- | :--- | :--- | :--- |
| **Feature Path** | Bug fixes, small features, refactors | Low | `/brainstorm` -> `/spec` -> `/todo` -> `/sprint` |
| **Project Path** | New products, major features, services | High | `/init` -> `/research` -> `/brainstorm` -> `/design-architect` -> `/tickets` -> `/sprint` |

---

### Project Path (Greenfield)

Use for: New products, major features, services

```txt
/init -> /research -> /brainstorm -> /design-architect -> /tickets -> /sprint
  P1       P1          P1                P3                  P3         P4
```

| Step | Command | What It Produces | Why You Cannot Skip |
| :--- | :--- | :--- | :--- |
| 1 | `/init` | `config.yaml`, `vault/`, `docs/` | No framework = no process = chaos |
| 2 | `/research` | Domain knowledge in `vault/research/` | No research = solving wrong problem |
| 3 | `/brainstorm` | Design decisions in `docs/plans/` | No design = unclear direction = wasted effort |
| 4 | `/design-architect` | Blueprint in `docs/architecture/` | No blueprint = architectural chaos = tech debt |
| 5 | `/tickets` | Epics/Stories in `docs/specs/epics.md` | No tickets = no traceability = scope creep |
| 6 | `/sprint` | Sprint plan | Ready for implementation |

---

### Feature Path (Daily Development)

Use for: Bug fixes, small features, refactors

```txt
/brainstorm -> /spec -> /todo -> /sprint
     P1         P2       P2        P4
```

| Step | Command | What It Produces | Why You Cannot Skip |
| :--- | :--- | :--- | :--- |
| 1 | `/brainstorm` | Design decisions in `docs/plans/` | No design = unclear direction = wasted effort |
| 2 | `/spec` | Tech spec in `docs/specs/` | No spec = unclear requirements = wrong implementation |
| 3 | `/todo` | Task list in `vault/tasks/todo.md` | No tasks = no progress tracking = blocked sprints |
| 4 | `/sprint` | Sprint plan | Ready for implementation |

---

### Existing Codebase (Brownfield)

Use for: Working with existing code

```txt
/scan -> /audit
  P1       P1
            |
            +--(clean)--> /sprint -> /test -> /code -> /review
            |
            +--(issues)--> /todo -> /sprint -> /test -> /code -> /review
```

| Step | Command | What It Produces | Why You Cannot Skip |
| :--- | :--- | :--- | :--- |
| 1 | `/scan` | `docs/project-context.md` | No scan = AI has no context = hallucinations |
| 2 | `/audit` | Security and tech debt report | No audit = hidden issues = production failures |
| 3 | `/todo` | Task list (if issues found) | No tasks = no plan = random fixes |

---

### Daily Dev Loop (Sprint)

Use for: Active development cycle

```txt
/sprint -> /test -> /code -> /review -> /docs -> /clean
    ^                                                     |
    |_________________ (next sprint) _____________________|
```

**Phase:** P4 (all commands)

| Step | Command | What It Produces | Why You Cannot Skip |
| :--- | :--- | :--- | :--- |
| 1 | `/sprint` | Sprint scope | No sprint = no focus = thrashing |
| 2 | `/test` | Failing tests | No tests = no verification = bugs in production |
| 3 | `/code` | Implementation | Write code to pass tests (TDD green) |
| 4 | `/review` | Quality gate | No review = bugs, security issues, tech debt |
| 5 | `/docs` | Updated documentation | No docs = knowledge lost = maintenance nightmare |
| 6 | `/clean` | Archived artifacts | No clean = workspace clutter = context pollution |

---

## Anti-Pattern Warning

NEVER skip planning. This is the #1 cause of project failure:

```txt
Idea -.-> SKIPPING PLANNING -.-> /code --> FAIL: Rework, Bugs, Scope Creep
```

### What Happens When You Skip:

| Skip This | Consequence |
| :--- | :--- |
| `/brainstorm` | Solving the wrong problem, wasted implementation |
| `/spec` | Unclear requirements, rework, wrong implementation |
| `/design-architect` | Architectural chaos, tech debt, impossible to scale |
| `/tickets` | No traceability, scope creep, stakeholder confusion |
| `/todo` | No progress tracking, blocked sprints, thrashing |
| `/test` | Bugs in production, regressions, broken features |
| `/review` | Security vulnerabilities, tech debt accumulation |

---

## If You Are Stuck

```txt
Stuck on logic?        -> /likeaboss      (roundtable of experts)
Need external data?    -> /mcp            (MCP servers: Jira, Figma, etc.)
Plan is wrong?         -> /rethink        (emergency pivot)
Declutter workspace?   -> /clean          (archive to _archive/)
Lost entirely?         -> /start          (you are here)
```