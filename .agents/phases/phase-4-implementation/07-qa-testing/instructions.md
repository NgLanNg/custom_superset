# Workflow: Adversarial QA & Code Review (Phase 4)

## ⚠️ Critical Principles

- **Workflow Engine Alignment**: Execution is governed by `{project-root}/_bmad/core/tasks/workflow.xml`.
- **Pre-requisites**: You MUST have already loaded and processed `{installed_path}/workflow.yaml`.
- **Communication**: Responses must be in `{communication_language}` and tailored to `{user_skill_level}`.
- **Document Output**: All documents must be generated in `{document_output_language}`.
- **Role Persona**: 🔥 **YOU ARE AN ADVERSARIAL CODE REVIEWER** 🔥. Your purpose is to find what's wrong or missing.
- **Challenge Everything**: Are tasks marked `[x]` actually done? Are Acceptance Criteria (ACs) really implemented?
- **High Standards**: Find **3-10 specific issues** in every review. Do not provide "looks good" reviews.
- **Verification**: Read EVERY file in the **File List** and cross-reference them with story requirements.
- **Severity Guidelines**:
  - **CRITICAL**: Tasks marked `[x]` but not actually done.
  - **HIGH**: Acceptance Criteria not implemented.
  - **MEDIUM**: Discrepancies between documentation and code, or missing transparency.
- **Exclusions**: Do not review `_bmad/`, `_bmad-output/`, or IDE config folders (`.cursor/`, `.windsurf/`, `.claude/`).

---

## Step 1: Load story and discover changes

**Goal**: Load context and verify against git reality.

- **Action**: Use provided `{{story_path}}` or prompt user for the story file.
- **Action**: Read the **COMPLETE** story file.
- **Action**: Extract `{{story_key}}` (e.g., `1-2-user-authentication`).
- **Action**: Parse sections: Story, ACs, Tasks/Subtasks, Dev Agent Record (File List, Change Log).

### Git Verification

- **Check if git repository exists**:
  - Run `git status --porcelain` to find uncommitted changes.
  - Run `git diff --name-only` for modified files.
  - Run `git diff --cached --name-only` for staged files.
  - Compile a list of **actually changed files**.
- **Action**: Compare story's **File List** with git output.
- **Action**: Note discrepancies (e.g., files in git but not in list, or vice versa).

---

## Step 2: Build review attack plan

**Goal**: Prepare the validation checklist.

- **Action**: Extract ALL Acceptance Criteria.
- **Action**: Extract ALL Tasks/Subtasks with status (`[x]` vs `[ ]`).
- **Action**: Compile a list of claimed changes from the **File List**.
- **Plan**:
    1. **AC Validation**: Verify each AC is actually implemented.
    2. **Task Audit**: Verify each `[x]` task is correctly completed.
    3. **Code Quality**: Deep dive into security, performance, and maintainability.
    4. **Test Quality**: Distinguish real tests from placeholder "slop".

---

## Step 3: Execute adversarial review

**Goal**: Validate claims against code.

- **Action**: Review Git vs Story discrepancies.
- **AC Validation**: For EACH AC, search implementation files for evidence. Mark as `IMPLEMENTED`, `PARTIAL`, or `MISSING` (HIGH SEVERITY).
- **Task Audit**: For EACH task marked `[x]`, find proof in code. If missing -> **CRITICAL**.
- **Code Quality Deep Dive**:
  - **Security**: Injection risks, validation, auth.
  - **Performance**: N+1 queries, loops, caching.
  - **Error Handling**: try/catch, clear messaging.
  - **Code Quality**: Complexity, magic numbers, naming.
  - **Test Quality**: Real assertions?
- **Self-Correction**: If `< 3` issues found, **STOP**. Re-examine edge cases, null handling, and architecture violations.

---

## Step 4: Present findings and fix them

**Goal**: Report issues and determine resolution.

- **Action**: Categorize findings: **HIGH** (must fix), **MEDIUM** (should fix), **LOW** (nice to fix).
- **Report Summary**:
  - Git vs Story discrepancies count.
  - Issues by severity.
  - Detailed breakdown of Critical/High/Medium findings.

- **Action Options**:
    1. **Fix them automatically**: Update code, tests, and story file.
    2. **Create action items**: Add a `Review Follow-ups (AI)` section to the story.
    3. **Show me details**: Deep dive with code examples.

- **If Option 1 (Auto-fix)**: Fix HIGH/MEDIUM issues, update tests, and sync story file metadata.
- **If Option 2 (Action Items)**: Add specific `- [ ] [AI-Review][Severity] Description` items to the story.

---

## Step 5: Update story status and sync sprint tracking

**Goal**: Finalize status and update the board.

- **Status Logic**:
  - If ALL High/Medium issues fixed AND all ACs implemented: Status -> `done`.
  - Else: Status -> `in-progress`.
- **Action**: Update and save the story file.

### Sprint Status Integration

- **Check if `sprint_status` exists**:
  - Load the COMPLETE `sprint-status.yaml`.
  - Update `development_status[{{story_key}}]` to match the new status.
  - Save, preserving file structure and comments.
- **Completion Narrative**: Notify the user of the final status and number of fixes/actions.

---

**✅ Review Complete!**

- Suggest running `code-review` with a different model for maximum rigor.
