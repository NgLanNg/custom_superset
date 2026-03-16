# Security Audit Report -- Scenario Plugin

**Date:** 2026-03-11
**Scope:** Custom scenario plugin code only (not core Superset)

## Summary

| Severity | Count | Key Categories |
| -------- | ----- | -------------- |
| HIGH | 5 | Info disclosure, mass assignment, unauthenticated endpoint |
| MEDIUM | 12 | Hardcoded creds, input validation, shell injection, CORS |
| LOW | 8 | Type safety, error forwarding, dynamic keys |
| INFO | 2 | License headers, SSL flag style |

---

## HIGH

### F-01 -- DB Exception Leaked to HTTP Response

**Files:** `scenario_writeback.py:145`, `growth_config_view.py:66,163`, `opu_config_view.py:66,159`

All `except` blocks return `f"Database write failed: {str(e)}"` to the client. Exposes table names, column names, PostgreSQL error codes.

**Fix:** Return generic `"An internal error occurred."` and log `str(e)` server-side only.

### F-04 -- Mass Assignment via Object Spread in OPU Payload

**File:** `useOPUConfig.ts:55-61`

`...currentRow` spreads all API-returned fields (including `id`, `updated_at`) into the POST payload. If the backend ever exposes internal fields, they are forwarded unconditionally.

**Fix:** Build payload explicitly from only the fields the backend accepts.

### F-05 -- Unauthenticated Health Endpoint Discloses Infrastructure

**File:** `scenario_writeback.py:159-161`

`/api/v1/scenario/health` has no `@has_access_api`. Returns `"db": "postgresql"` to any anonymous request.

**Fix:** Add `@has_access_api` or remove the `"db"` key.

### F-10 -- `year` Field Not Validated

**File:** `scenario_writeback.py:55-60`

No type coercion or range check on `year`. Client can pass strings or extreme integers.

**Fix:** Cast to `int`, validate 2020-2040 range.

### F-11 -- `scenario_id` Field Not Validated

**File:** `scenario_writeback.py:134`

Part of the unique constraint but accepted raw without length or type validation.

**Fix:** Apply `_MAX_FIELD_LEN` check.

---

## MEDIUM

### F-02 -- PII Logged

**Files:** `scenario_writeback.py:81,107`

`logger.info(f"Writeback payload: {payload}")` logs full payload including user email.

**Fix:** Log only non-PII identifiers.

### F-06 -- Hardcoded DB Credentials in Config

**File:** `superset_config.py:12`

`_PG_URI = "postgresql+psycopg2://superset:superset@localhost:5432/superset"` -- silent fallback.

**Fix:** Raise startup error if no URI configured (like SECRET_KEY).

### F-07 -- Hardcoded Credentials in docker-compose

**File:** `docker-compose.yml:6-8`

`POSTGRES_USER: superset`, `POSTGRES_PASSWORD: superset` committed as plaintext.

**Fix:** Use `${POSTGRES_PASSWORD}` from `.env` file.

### F-08 -- DB Port Exposed on All Interfaces

**File:** `docker-compose.yml:9`

`"5432:5432"` binds on `0.0.0.0`.

**Fix:** Bind to loopback: `"127.0.0.1:5432:5432"`.

### F-09 -- SESSION_COOKIE_SAMESITE = None Without Secure

**File:** `superset_config.py:38`

Defeats CSRF protection without `SESSION_COOKIE_SECURE = True`.

**Fix:** Set `SESSION_COOKIE_SECURE = True` alongside.

### F-12 -- `region` Field Has No Length Cap

**File:** `opu_config_view.py:86-96`

Optional field can be arbitrarily long.

**Fix:** Apply `_MAX_FIELD_LEN` when provided.

### F-13 -- `status` Field Not Validated Against Allowlist

**File:** `growth_config_view.py:153`

Any string accepted. UI has 3 options but backend has no check.

**Fix:** Validate against `{"On Track", "Delayed", "Cancelled"}`.

### F-14 -- Raw DB Exception in GET Error Responses

**Files:** `growth_config_view.py:66`, `opu_config_view.py:66`

Same as F-01 but on read paths.

### F-15 -- Unsafe xargs env-file Parsing

**File:** `migrate_rds.sh:11`

`export $(grep -v '^#' "$ENV_FILE" | xargs)` fails on passwords with spaces.

**Fix:** Use `set -a; source "$ENV_FILE"; set +a`.

### F-16 -- Unquoted Shell Variables in psql Command

**File:** `migrate_rds.sh:29,33-36`

`psql $PSQL_ARGS` -- word splitting risk.

**Fix:** Use array: `psql "${PSQL_ARGS[@]}"`.

### F-17 -- PUBLIC_ROLE_LIKE = "Gamma"

**File:** `superset_config.py:63`

Grants Gamma permissions to unauthenticated users.

**Fix:** Use guest token mechanism instead.

### F-23 -- Real RDS Hostname in Template

**File:** `.env.production.template:9`

`peth_prod.rds.amazonaws.com` -- may be real infrastructure name.

**Fix:** Replace with generic placeholder.

---

## LOW

| ID | File | Issue |
| -- | ---- | ----- |
| F-18 | `useGrowthConfig.ts:6`, `useOPUConfig.ts:6` | `any[]` state type -- no schema enforcement |
| F-19 | `useGrowthConfig.ts:24`, `useOPUConfig.ts:24` | Backend error messages forwarded raw to UI |
| F-20 | `useGrowthConfig.ts:38`, `useOPUConfig.ts:38` | `field` param is unconstrained dynamic key |
| F-21 | `useWriteBack.ts:59-78` | `saveBatch` partial failure leaves UI inconsistent |
| F-22 | `superset_config.py:44` | Wildcard `allow_headers` in CORS |
| F-24 | All SQL DDL files | No GRANT statements -- violates least privilege |

---

## Remediation Priority

**Before production deployment:**
1. F-01/F-14 -- Stop leaking DB exceptions
2. F-06/F-07/F-08 -- Remove hardcoded credentials, restrict port
3. F-04 -- Fix mass assignment in OPU payload
4. F-10/F-11 -- Validate `year` and `scenario_id`

**Before hardening sign-off:**
5. F-09 -- Fix SameSite cookie config
6. F-13 -- Status field allowlist
7. F-15/F-16 -- Fix shell script safety
8. F-23 -- Audit RDS hostname
