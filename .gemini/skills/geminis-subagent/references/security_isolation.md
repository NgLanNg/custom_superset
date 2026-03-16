# Security Isolation & Sandboxing (v0.1.8)

## 1. Git Worktree Jailing

Sub-agents never operate on your active branch.

- **Isolation**: Each task gets a dedicated worktree in `.agents/worktrees/[session_id]`.
- **Branching**: Work is performed on a unique branch `subgemi/[session_id]`.
- **Metadata Protection**: `.git` directory permissions are managed carefully during worktree cleanup.

> ⚠️ **Audit Note (v0.1.8):** The previous implementation used `chmod 0o666` (world-writable) on the `.git`
> directory during cleanup. This is a known issue tracked in `docs/warnings/security-issues.md`.
> The recommended fix is `chmod 0o755`. Contributions welcome.

## 2. Safety Sandbox (Binary Masking)

Destructive or sensitive commands are blocked via a "Safety Bin" prepended to the process `$PATH`.
This is implemented in `infrastructure/executor.py::_setup_safety_sandbox()`.

**Blocked Binaries (default):**

- **Destructive**: `rm`, `mv`, `cp` (blocks arbitrary deletions).
- **Cloud/Infra**: `kubectl`, `terraform`, `aws`, `gcloud`, `deploy`.

> ⚠️ **Audit Note (v0.1.8):** The sandbox can be bypassed using absolute paths (e.g. `/bin/rm`) or
> Python builtins. For production hardening, consider wrapping sub-agent processes with `sandbox-exec`
> (macOS) or `bubblewrap`/`nsjail` (Linux). See `docs/warnings/security-issues.md`.

## 3. Path Traversal Protection

All file paths and session identifiers are validated by `is_safe_path()` and `validate_identifier()` in `core/delegator.py`:

- Sub-agents cannot escape `WORKSPACE_ROOT`.
- `..` and absolute paths outside the project boundary are blocked.
- Symbolic links are resolved and checked before use.

## 4. Credential Security

- **No hardcoded secrets** should exist in source files.
- **`.env`** files are gitignored but should not be used to store PyPI tokens or API keys in plaintext.
  Use a secure credential manager (1Password CLI `op run`, `keyring`, or CI/CD environment variables).
