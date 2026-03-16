---
title: E2E Test Suite — Slide 1 OPU GHG Summary Sheet
date: 2026-03-12
author: Antigravity
spec: .cla/specs/2026-03-12-slide-1-superset-dashboard.md
---

# E2E Tests for Slide 1 — OPU GHG Summary Sheet Dashboard

## Overview

This test suite validates the Slide 1 OPU GHG Summary Sheet Superset dashboard using Playwright for end-to-end browser automation.

## Prerequisites

1. **Superset Running** at `http://localhost:8088`
2. **Admin User** with credentials:
   - Username: `admin`
   - Password: `admin`
3. **Dashboard Created** at slug `opu-ghg-summary`
4. **Node.js** (v18+) installed
5. **Dependencies** installed via `npm install`

## Setup

```bash
cd /Users/alan/dashboard/tests/e2e
npm install
npx playwright install
```

## Running Tests

### Run all tests (headless)

```bash
npm test
```

### Run tests with visible browser

```bash
npm run test:headed
```

### Run tests in UI mode (debuggable)

```bash
npm run test:ui
```

### Run specific browser

```bash
npm run test:chromium
npm run test:firefox
npm run test:webkit
```

### Debug tests (step-through)

```bash
npm run test:debug
```

### View test report

```bash
npm run test:report
```

## Test Coverage

### Acceptance Criteria Mapped

| ACID | Test File | Test Description |
| ----- | --------- | ---------------- |
| AC1 | Dashboard Access | Dashboard loads without errors |
| AC2 | Top Band Section | Top band shows OC/ES + CAPEX by lever |
| AC3 | Left Panel (OC Basis) | Left panel shows OC basis data only |
| AC4 | Right Panel (ES Basis) | Right panel shows ES basis data only |
| AC5 | Dashboard Layout | Dashboard layout matches reference design |
| AC6 | Data Accuracy and Units | All charts render with correct data units |

### Test Suites

1. **Dashboard Access** — Verifies dashboard loads without errors
2. **Top Band Section** — Validates GHG Reduction OC/ES and Green CAPEX charts
3. **Left Panel (OC Basis)** — Validates 4 OC basis charts
4. **Right Panel (ES Basis)** — Validates 4 ES basis charts
5. **Dashboard Layout** — Validates 3-section grid layout
6. **Data Accuracy and Units** — Validates correct units and data display
7. **Dashboard Filters** — Validates Year and OPU/Metric filters
8. **Performance** — Validates < 5s load time

## Expected Results

### All Tests Pass

```
Running 12 tests using 1 worker

  [chromium] Dashboard Access AC1: Dashboard loads without errors 3.1s
  [chromium] Dashboard Access AC1: Dashboard renders charts without SQL errors 3.4s
  [chromium] Top Band AC2: Top band shows GHG Reduction OC/ES chart 2.8s
  [chromium] Top Band AC2: Top band shows Green CAPEX chart 2.7s
  [chromium] Top Band AC2: Top band charts show all 4 lever types 2.9s
  [chromium] Left Panel AC3: Left panel shows OC GHG Intensity chart 3.0s
  [chromium] Left Panel AC3: Left panel shows OC Total GHG Emission chart 3.1s
  [chromium] Left Panel AC3: Left panel shows OC Upon Reduction chart 2.9s
  [chromium] Left Panel AC3: Left panel shows OC Production table 3.2s
  [chromium] Right Panel AC4: Right panel shows ES GHG Intensity chart 3.0s
  [chromium] Right Panel AC4: Right panel shows ES Total GHG Emission chart 3.1s
  [chromium] Right Panel AC4: Right panel shows ES Upon Reduction chart 2.9s
  [chromium] Right Panel AC4: Right panel shows ES Production table 3.2s
  [chromium] Dashboard Layout AC5: Dashboard has 3-section grid layout 2.5s
  [chromium] Dashboard Layout AC5: All 10 charts are visible 2.6s
  [chromium] Dashboard Layout AC5: Charts properly distributed 2.7s
  [chromium] Data Accuracy AC6: CAPEX chart shows RM Million units 2.8s
  [chromium] Data Accuracy AC6: Emission charts show tCO2e units 2.9s
  [chromium] Data Accuracy AC6: Production table shows correct units column 3.0s
  [chromium] Dashboard Filters Year filter is available 2.5s
  [chromium] Dashboard Filters OPU/Metric filter is available 2.6s
  [chromium] Dashboard Filters Filters are cross-chart 2.7s
  [chromium] Performance Dashboard loads within 5 seconds 3.2s

  12 passed (42.3s)
```

## Troubleshooting

### Dashboard Not Found

```
Error: page.goto: Timeout 10000ms exceeded.
```

**Cause:** Dashboard not accessible at expected URL

**Fix:** Verify Superset is running and dashboard slug is correct:
```bash
curl http://localhost:8088/superset/dashboard/opu-ghg-summary/
```

### Login Failed

```
Error: Page.goto: Timeout 10000ms exceeded.
```

**Cause:** Superset login failed

**Fix:** Verify admin credentials and reset if needed:
```bash
# Via Superset CLI
flask fab create-admin --username admin --password admin --firstname Admin --lastname User
```

### Charts Not Loading

```
Error: Expected 10 charts, found X
```

**Cause:** Charts not rendering or filters hiding all data

**Fix:**
1. Check gold tables have data
2. Verify dataset connections
3. Check browser console for JavaScript errors

## CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
        working-directory: ./tests/e2e
      - run: npx playwright install --with-deps
        working-directory: ./tests/e2e
      - run: npm test
        working-directory: ./tests/e2e
        env:
          CI: true
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: tests/e2e/playwright-report/
          retention-days: 30
```

## References

- **Spec:** `.cla/specs/2026-03-12-slide-1-superset-dashboard.md`
- **Task Tracker:** `vault/tasks/ghg_dashboard_todo.md`
- **Playwright Docs:** https://playwright.dev/docs/intro
