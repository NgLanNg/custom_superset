# Test Report: Failed to Save Draft

**Date:** 2026-03-16
**Component:** Scenario Planning Dashboard
**Issue:** Users see "Failed to save draft" error message in UI

---

## Executive Summary

| Status | Finding |
|--------|---------|
| **Root Cause** | Authentication failure (HTTP 401 Unauthorized) |
| **Severity** | High - Blocks core functionality |
| **Impact** | Users cannot save scenario configurations |

---

## Test Environment

| Item | Value |
|------|-------|
| Superset URL | http://localhost:8088 |
| Frontend Port | 9000 (dev server) |
| Database | PostgreSQL (localhost) |
| Plugin | plugin-chart-scenario |

---

## Investigation Results

### 1. API Endpoint Verification

| Endpoint | Method | HTTP Status | Result |
|----------|--------|-------------|--------|
| `/api/v1/scenario/metadata/` | GET | 401 | Unauthorized |
| `/api/v1/scenario/metadata/` | POST | 401 | Unauthorized |
| `/api/v1/scenario/metadata/<id>` | PUT | 401 | Unauthorized |

**Conclusion:** Endpoints exist but require authentication.

### 2. Database Verification

```sql
\dt scenario_metadata
```

| Schema | Name | Type | Owner |
|--------|------|------|-------|
| public | scenario_metadata | table | superset |

**Conclusion:** Table exists and is accessible.

### 3. Code Analysis

**Error Source:** `ScenarioChart.tsx:138`

```typescript
} catch (err) {
  message.error('Failed to save draft');
  console.error('Save draft error:', err);
}
```

**Save Draft Flow:**

1. User clicks "Save Draft" button
2. `handleSaveDraft()` called (line 75)
3. Validates scenario name is not empty
4. Calls `SupersetClient.post()` to `/api/v1/scenario/metadata/`
5. If successful, calls `saveFlusherRef.current?.()` to flush emission edits
6. On failure, catches error and shows "Failed to save draft"

**Backend Endpoints Exist:**

| File | Endpoint |
|------|----------|
| `scenario_metadata.py` | `/api/v1/scenario/metadata/` (POST, GET) |
| `scenario_metadata.py` | `/api/v1/scenario/metadata/<id>` (GET, PUT) |
| `scenario_metadata.py` | `/api/v1/scenario/metadata/<id>/submit` (POST) |
| `scenario_writeback.py` | `/api/v1/scenario/emission-sources/batch` (POST) |

---

## Root Cause Analysis

### Primary Cause: Authentication Failure

The API returns `401 Unauthorized`, indicating:

1. **Session expired** - Flask session cookie no longer valid
2. **User not logged in** - No valid session cookie sent
3. **CSRF token missing** - Superset requires CSRF token for POST/PUT

### Potential Secondary Causes

| Cause | Likelihood | Notes |
|-------|------------|-------|
| CORS issue | Low | Same-origin should work |
| Network timeout | Low | Would show different error |
| Backend crash | Low | Process is running (PID 88676) |

---

## Reproduction Steps

1. Open Scenario Planning dashboard at `/superset/dashboard/scenario-planning/`
2. Enter scenario name and description
3. Modify emission source values
4. Click "Save Draft" button
5. Observe error message: "Failed to save draft"

---

## Recommended Fixes

### Option 1: Re-authenticate (Immediate)

1. Navigate to http://localhost:8088/login/
2. Log in with valid credentials
3. Return to Scenario Planning dashboard
4. Retry save operation

### Option 2: Check Browser Session

1. Open DevTools (F12)
2. Go to Application > Cookies
3. Verify session cookie exists for localhost:8088
4. If missing, log in again

### Option 3: Add CSRF Token (Code Fix)

If CSRF is required, modify frontend to include CSRF token:

```typescript
// In ScenarioChart.tsx
import { SupersetClient } from '@superset-ui/core';

const csrfToken = document.querySelector('meta[name="csrf_token"]')?.getAttribute('content');

await SupersetClient.post({
  endpoint: '/api/v1/scenario/metadata/',
  jsonPayload: { ... },
  headers: {
    'X-CSRFToken': csrfToken || '',
  },
});
```

### Option 4: Verify Backend Auth Decorator

Check that `@has_api_access` decorator is properly handling session auth in `scenario_metadata.py`.

---

## Test Cases to Verify Fix

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| TC-001 | Save new scenario with valid session | Success message, record created |
| TC-002 | Update existing scenario | Success message, record updated |
| TC-003 | Save with expired session | Redirect to login |
| TC-004 | Save with invalid CSRF | Clear error message |
| TC-005 | Save emission sources after metadata | Both succeed |

---

## Next Steps

1. **User Action Required:** Check browser console for exact error
2. **Verify:** Are you logged in to Superset?
3. **Test:** Try logging out and back in
4. **Report:** Share browser console errors if issue persists

---

## Appendix: Related Files

| File | Purpose |
|------|---------|
| `superset/superset-frontend/plugins/plugin-chart-scenario/src/ScenarioChart.tsx` | Frontend save logic |
| `superset/superset/views/scenario_metadata.py` | Backend API endpoints |
| `superset/superset/views/scenario_writeback.py` | Emission sources writeback |

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Investigator | Claude Code | 2026-03-16 |
| Status | **Awaiting user feedback** | |