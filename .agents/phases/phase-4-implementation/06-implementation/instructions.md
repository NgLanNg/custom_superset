# Workflow: Developer Implementation (Phase 4)

## ⚠️ Critical Principles

- **Workflow Engine Alignment**: Execution is governed by `{project-root}/_bmad/core/tasks/workflow.xml`.
- **Pre-requisites**: You MUST have already loaded and processed `{installed_path}/workflow.yaml`.
- **Communication**: Responses must be in `{communication_language}` and tailored to `{user_skill_level}`.
- **Document Output**: All documents must be generated in `{document_output_language}`.
- **Story File Fidelity**: Only modify specific areas: Tasks/Subtasks checkboxes, Dev Agent Record (Debug Log, Completion Notes), File List, Change Log, and Status.
- **Sequential Execution**: Execute ALL steps in exact order; do NOT skip steps.
- **Continuous Momentum**: Do NOT stop for session boundaries. Continue until the story is COMPLETE (all ACs satisfied and tasks checked) unless a HALT condition or user instruction triggers.
- **No Early Pauses**: Do NOT schedule a "next session" or request review pauses. Completion is decided only at the final stages.

---

## Step 1: Find next ready task and load it

**Tag**: `task-status`

### Task Discovery

- **CRITICAL**: MUST read COMPLETE `docs/tasks.md` from start to end.
- Parse the list to find the **FIRST** task where 'Status' equals `ready`.
- Identify the explicit Acceptance Criteria and any dependencies.

- **If no ready task found**:
  - Display summary of current task status.
  - **Options**:
    1. Run `/plan-tasks` to generate a new task breakdown.
    2. Suggest user manually unblock a task.
  - **HALT conditions**: Task requirements or scope are ambiguous.

### Context Load

- Load the task definition into active context.
- Proceed to Step 2.

---

## Step 2: Load project context and story information

- **Critical**: Load all available context to inform implementation.
- **Action**: Load `{project_context}` for coding standards.
- **Action**: Use enhanced story context (architecture requirements, technical specs) to inform implementation decisions.

---

## Step 3: Detect review continuation

- **Action**: Check for "Senior Developer Review (AI)" or "Review Follow-ups (AI)" sections.
- **If Review exists**:
  - Set `review_continuation = true`.
  - Extract outcome, date, action items, and severity.
  - Store pending review items.
  - **Strategy**: Prioritize follow-up tasks (marked `[AI-Review]`) before regular tasks.
- **Else**:
  - Set `review_continuation = false`.
  - Start fresh implementation.

---

## Step 4: Mark story in-progress

**Tag**: `sprint-status`

- **If `sprint_status` exists**:
  - Find state of `{{story_key}}`.
  - If `ready-for-dev` or `review_continuation`: Update status to `in-progress`.
- **Else**:
  - Track progress in story file only.

---

## Step 5: Implement task (Red-Green-Refactor)

**CRITICAL**: FOLLOW THE STORY FILE TASKS SEQUENCE EXACTLY. NO DEVIATION.

### 🔴 RED Phase

- Write **FAILING** tests first for the task functionality.
- Confirm tests fail to validate test correctness.

### 🟢 GREEN Phase

- Implement **MINIMAL** code to make tests pass.
- Run tests to confirm passing.
- Handle error conditions and edge cases.

### 🔵 REFACTOR Phase

- Improve code structure while keeping tests green.
- Ensure compliance with architecture patterns in **Dev Notes**.

- **Note**: Document technical approach in `Dev Agent Record -> Implementation Plan`.
- **HALT conditions**: New dependencies required, 3 consecutive implementation failures, or missing configuration.
- **Strict Rule**: NEVER implement anything not mapped to a task. NEVER skip a task or proceed without passing tests.

---

## Step 6: Author comprehensive tests

- Create unit tests for business logic.
- Add integration tests for component interactions.
- Include end-to-end tests for critical flows if required.
- Cover edge cases and error handling.

---

## Step 7: Run validations and tests

- Infer repo test framework from project structure.
- Run all existing tests to ensure no regressions.
- Run new tests to verify implementation.
- Run linting/quality checks.
- **Stop and Fix** if any tests or regressions fail.

---

## Step 8: Validate and mark task complete

**CRITICAL**: NEVER mark a task complete unless ALL conditions are met.

- **Validation Gates**:
  - Verify tests exist and pass 100%.
  - Confirm implementation matches task specification exactly.
  - Check that Acceptance Criteria are satisfied.
  - Run full suite for regression check.

- **Review Follow-up Handling**:
  - If task has `[AI-Review]` prefix:
    - Mark checkbox in "Review Follow-ups" section.
    - Mark corresponding item in "Senior Developer Review (AI)" action items.
    - Add resolution note to `Dev Agent Record`.

- **Completion**:
  - Mark task/subtasks `[x]`.
  - Update **File List** (relative paths).
  - Add completion notes to `Dev Agent Record`.
- **Transition**:
  - Save story file.
  - If tasks remain: Go to **Step 5**.
  - If no tasks remain: Go to **Step 9**.

---

## Step 9: Story completion & Review gating

**Tag**: `sprint-status`

- **Verify**: All tasks marked `[x]`, regression suite passed, File List updated.
- **Definition of Done (DoR) Validation**:
  - All tasks/subtasks complete.
  - ACs satisfied.
  - Comprehensive tests added and passing.
  - Code quality checks passed.
  - Implementation notes and Change Log updated.
- **Status Update**:
  - Update story Status to `review`.
  - If `sprint_status` exists: Update `development_status[{{story_key}}] = "review"`.
- **HALT**: If any DoD gate fails (incomplete tasks, regression failures, missing File List).

---

## Step 10: Completion communication & User support

- **Final Action**: Execute DoD checklist again using validation framework.
- **Developer Record**: Prepare concise summary in `Completion Notes`.
- **Communication**: Notify `{user_name}` that the story is ready for review.
- **Support**: Offer explanations based on `{user_skill_level}`.
- **Logistical Next Steps**:
  - Suggest `code-review` workflow.
  - Suggest checking `sprint_status` for progress.
- **Tip**: Run `code-review` using a **different** LLM for best results.
