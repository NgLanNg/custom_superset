# Change Proposal: Fix E2E Tests - Database Reset Issue

## Root Cause

The E2E tests fail because the integration test teardown (`tests/integration_tests/conftest.py` lines 136-145) drops ALL database tables at the end of the test session for test isolation. This is intentional for Python unit tests but breaks E2E tests that require a live database with scenario data.

### Why Change

1. **Database reset after test session** - The `setup_sample_data` fixture drops tables at session end, removing charts, dashboards, and datasets
2. **E2E tests run against live server** - Tests navigate to `explore/?slice_id=2` and `/superset/dashboard/scenario-planning/` but these don't exist
3. **Test failure rate: 80%** - 4 out of 5 tests fail due to missing data

## Impact Analysis

### Scope
- **Add:** Database seeding step to E2E test setup
- **Modify:** Playwright global-setup.ts to seed data before tests
- **New:** playwright/seed-database.ts script for data preparation

### What Stays
- Epic 5-13 - All existing epic work
- Integration test teardown - No changes to Python tests

### What Changes
- E2E test pipeline now includes database seeding step
- Tests run with verified scenario data (chart, dashboard, dataset)

### Timeline
- **Estimate:** +2h to add seeding infrastructure
- **No timeline extension needed** - within sprint buffer

## Proposal

### Actions

1. **Create database seeding script** (`playwright/seed-database.ts`)
   - Use Superset REST API to create scenario chart
   - Use Superset REST API to create scenario-planning dashboard
   - Create necessary datasets via database connection
   - Links chart to dashboard

2. **Update global-setup.ts** (`playwright/global-setup.ts`)
   - Add seeding step after authentication
   - Ensure database is ready before E2E tests run

3. **Verify E2E tests pass**
   - Run full test suite
   - Confirm all 5 tests pass

### Files Affected

| File | Change |
|------|--------|
| `playwright/global-setup.ts` | Add seeding step |
| `playwright/seed-database.ts` | NEW - database seeding logic |
| `playwright/tests/scenario.spec.ts` | Update to use seeded data |
| `vault/tasks/todo.md` | Add Epic 15 for E2E fix |

### Approvals Needed

- [ ] User approval to proceed with database seeding approach

### Updated Sprint Plan

After this change, the remaining work is:

| Epic | Objective | Status |
|------|-----------|--------|
| 5 | Chart & Dashboard | COMPLETE |
| 6 | Shared write-back package | COMPLETE |
| 7 | Refactor plugin | COMPLETE |
| 8 | Verification | COMPLETE (T24-T25) |
| 9 | dbt Gold Model | COMPLETE |
| 10 | Growth Config | COMPLETE |
| 11 | OPU Config | COMPLETE |
| 12 | Tableau Config | COMPLETE |
| 13 | Production RDS | COMPLETE |
| 14 | Scenario Creation Page | DEPRECATED |
| **15** | **E2E Test Fix** | **TODO** |

## Next Steps

1. Create `playwright/seed-database.ts` with seeding logic
2. Update `global-setup.ts` to run seeding
3. Run E2E tests to verify fix
4. Update documentation with new test approach

---

**Date:** 2026-03-13
**Author:** Claude
**Approval Status:** Awaiting user approval
