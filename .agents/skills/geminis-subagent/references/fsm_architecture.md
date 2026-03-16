# FSM Architecture & Self-Healing (v0.1.8)

## 1. The FSM Lifecycle

The `SubAgentFSM` in `core/engine.py` manages the following states:

| State | Description |
| :--- | :--- |
| `PENDING` | Initial state; tasks are queued by `run_sub_agent`. |
| `PREPARING_CONTEXT` | Packing context with Repomix (`--slim`, `--include`, `--exclude` apply here). |
| `EXECUTING_PROCESS` | Running the `gemini` CLI inside the sandboxed executor. |
| `VALIDATING_OUTPUT` | Inspecting `stdout` / `stderr` and parsing `fsm_payload_out.json` via `ResultParser`. |
| `HEALING` | Retrying on failure with augmented context (max 3 attempts). |
| `VERIFICATION` | Running the user-provided `--verify-cmd` (e.g. `pytest`). |
| `COMPLETED` | Successful termination. |
| `FAILED` | Permanent failure after all healing attempts are exhausted. |
| `CLEANUP` | Tearing down worktrees and tmux monitors. |

## 2. Self-Healing Mechanism

When a task fails or the verification command returns non-zero:

1. The FSM transitions to `HEALING`.
2. It captures the error output and current `git diff`.
3. It augments the original prompt with the failure context.
4. It restarts the execution loop (up to 3 times by default).

## 3. Rate Limit Resilience (v0.1.6+)

If a sub-agent hits a Gemini API rate limit:

- **Detection**: `stderr` is scanned for `429`, `Rate limit exceeded`, or `Resource exhausted`.
- **Backoff**: Transitions to `HEALING` and applies exponential backoff with jitter (`base_wait * 2^attempt + rand`).
- **Retry**: Re-executes without modifying the prompt — a clean retry.

## 4. Concurrency Gating (v0.1.8+)

Before the FSM is created, `run_sub_agent` in `core/delegator.py` checks the active session count:

```python
while session_manager.get_active_session_count() >= DEFAULT_MAX_CONCURRENT:
    logger.warning("Concurrency limit reached. Task is queued...")
    await asyncio.sleep(10)
```

This is a global gate — it applies across all lanes.

## 5. Output Parsing (v0.1.8+)

Result extraction is handled by `core/parser.py::ResultParser.parse_session_output()`:

1. **Primary**: Parse `fsm_payload_out.json` (written by the FSM directly).
2. **Fallback**: Scrape `stdout.log` for the first `{...}` JSON block or a ` ```json ``` ` block.
3. **Error**: Return a structured `{"error": "..."}` dict if both fail.

## 6. Metrics & Analytics

Each session generates ground-truth metrics stored in the registry:

- **`lines_added` / `lines_removed`**: Measured via `git diff --numstat`.
- **`total_tokens`**: Aggregated usage from the Gemini API.
- **`cost_usd`**: Calculated from token burn against model pricing table in `config.py`.
- **`heal_attempts`**: Count of auto-healing cycles triggered.
