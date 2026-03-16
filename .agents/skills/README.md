# Skills (Reference Only)

> These are imported examples from `affaan-m/everything-claude-code`. Many refer to `.agents/` paths and external tooling. Treat them as reference snippets only; do not assume they are runnable in this Vibe setup.

## How to Use

- JIT load only the specific skill file you need; do not bulk-load this folder.
- Ignore instructions that mention `.agents/` paths, marketplace commands, or external API keys unless you adapt them to `.agents/` and your stack.
- Prefer simple markdown skills as inspiration: `coding-standards.md`, `backend-patterns.md`, `project-guidelines-example.md`, `tdd-workflow/SKILL.md`, `security-review/SKILL.md`.
- Scripts under subfolders (e.g., `ai-multimodal`, `mcp-management`) are not wired into this repo; only use after adapting paths/env to `.agents/`.

## Integration Guidance

- Keep entry instructions under 500 lines; summarize before use.
- Do not load or reference `.agents/.env`, `.agents/mcp.json`, or marketplace hooks; they don’t exist here.
- If a reusable pattern emerges, promote it into `.agents/knowledge/10_PATTERNS.md` or `.agents/knowledge/11_TECH_STACK.md`.

## Safety

- Do not run bundled scripts without reviewing dependencies and side effects.
- Strip secrets and external tokens; this repo is workspace-scoped only.
