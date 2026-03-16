import { test, expect } from '@playwright/test';

/**
 * E2E Tests for Scenario Creation Page
 * 
 * Acceptance Criteria Tested:
 * - AC1: Page loads with metadata inputs visible
 * - AC2: Top tabs: 3 tabs present and switchable
 * - AC3: OPU sub-tabs: 6 sub-tabs visible and switchable
 * - AC4: ComparativeChart renders with dynamic title
 * - AC5: EditableDataTable renders with year columns
 * - AC6: Filter changes update chart title and table
 * - AC7: Cell edits POST to API and return 200
 * - AC8: Save Draft button creates scenario (POST 200)
 * - AC9: Submit button transitions to pending_approval
 */

const BASE_URL = 'http://localhost:9000';
const BACKEND_URL = 'http://localhost:8088';
const TARGET_URL = `${BASE_URL}/scenario/create/`;
const LOGIN_URL = `${BACKEND_URL}/login/`;

const USERNAME = 'admin';
const PASSWORD = 'admin';

test.describe('Scenario Creation Page E2E', () => {
  test.beforeEach(async ({ page }) => {
    // Login to Superset
    await page.goto(LOGIN_URL);
    await page.waitForLoadState('networkidle');
    await page.fill('input[name="username"]', USERNAME);
    await page.fill('input[name="password"]', PASSWORD);
    await page.click('button[type="submit"]');
    
    // Wait for redirect to welcome or dashboard list
    await page.waitForURL(/.*success.*/i, { timeout: 10000 }).catch(() => {});
    
    // Navigate to Scenario Creation Page
    await page.goto(TARGET_URL);
  });

  test('AC1: Page loads with metadata inputs visible', async ({ page }) => {
    // Wait for the main container or specific data-test element
    await page.waitForSelector('[data-test="scenario-name-input"]', { timeout: 20000 });
    
    await expect(page.locator('[data-test="scenario-name-input"]')).toBeVisible();
    await expect(page.locator('[data-test="scenario-description-input"]')).toBeVisible();
    await expect(page.locator('[data-test="save-draft-btn"]')).toBeVisible();
    await expect(page.locator('[data-test="submit-btn"]')).toBeVisible();
    
    // Verify no error banners from Ant Design
    const errorBanners = await page.locator('.ant-message-error, .ant-alert-error').count();
    expect(errorBanners).toBe(0);
  });

  test('AC2 & AC3: Navigation tabs and sub-tabs working', async ({ page }) => {
    await page.waitForSelector('[data-test="scenario-name-input"]', { timeout: 20000 });

    // Verify top tabs exist
    const topTabs = page.locator('.ant-tabs-tab');
    await expect(topTabs).toContainText(['Equity Share Configuration', 'Growth Configuration', 'OPU Configuration']);

    // Switch to OPU Configuration
    await page.click('.ant-tabs-tab-btn:has-text("OPU Configuration")');
    await expect(page.locator('.ant-tabs-tab-active')).toContainText('OPU Configuration');

    // Verify OPU sub-tabs exist
    const subTabs = page.locator('[data-test="sub-tabs"] .ant-tabs-tab');
    await expect(subTabs).toContainText(['Emission by Sources', 'Production', 'Emission by Gases', 'Energy Consumption', 'Intensity', 'Reduction']);
  });

  test('AC4, AC5, AC6: Chart and Filter sync', async ({ page }) => {
    await page.waitForSelector('[data-test="scenario-name-input"]', { timeout: 20000 });
    
    // Select OPU Configuration
    await page.click('.ant-tabs-tab-btn:has-text("OPU Configuration")');
    
    // Wait for chart and table to load (Emission by Sources is default)
    await page.waitForSelector('[data-test="chart-title"]', { timeout: 10000 });
    
    const chartTitle = page.locator('[data-test="chart-title"]');
    await expect(chartTitle).toContainText('Comparative Total GHG Emissions');

    // Filter BU: LNGA
    await page.click('[data-test="filter-bu"] .ant-select-selector');
    await page.click('.ant-select-item-option-content:has-text("LNGA")');
    await expect(chartTitle).toContainText('– LNGA');

    // Filter OPU: MLNG (should override BU in title)
    await page.click('[data-test="filter-opu"] .ant-select-selector');
    await page.click('.ant-select-item-option-content:has-text("MLNG")');
    await expect(chartTitle).toContainText('– MLNG');

    // Table Year Columns
    const yearHeaders = page.locator('.ant-table-thead th').filter({ hasText: /20\d{2}/ });
    expect(await yearHeaders.count()).toBeGreaterThan(0);
  });

  test('AC7: Cell edits persist via API', async ({ page }) => {
    await page.waitForSelector('[data-test="scenario-name-input"]', { timeout: 20000 });
    await page.click('.ant-tabs-tab-btn:has-text("OPU Configuration")');
    
    // Wait for table data
    await page.waitForSelector('.ant-table-row', { timeout: 10000 });

    // Intercept POST request for cell edit
    const postPromise = page.waitForResponse(response => 
      response.url().includes('/api/v1/scenario/emission-sources') && 
      response.request().method() === 'POST'
    );

    // Find first editable cell (numeric value)
    const cell = page.locator('.ant-table-cell').filter({ hasText: /^\d+(\.\d+)?$/ }).first();
    await cell.click();
    
    // Type new value
    const input = page.locator('input').filter({ hasValue: /^\d+(\.\d+)?$/ });
    await input.fill('999.9');
    await input.press('Enter');

    const response = await postPromise;
    expect(response.status()).toBe(200);
    
    // Verify success message
    await expect(page.locator('.ant-message-success')).toBeVisible();
  });

  test('AC8 & AC9: Save Draft and Submit workflow', async ({ page }) => {
    await page.waitForSelector('[data-test="scenario-name-input"]', { timeout: 20000 });
    
    const randomName = `E2E Scenario ${Math.floor(Math.random() * 10000)}`;
    await page.fill('[data-test="scenario-name-input"]', randomName);
    await page.fill('[data-test="scenario-description-input"]', 'Automated E2E Test');

    // Save Draft intercept
    const savePromise = page.waitForResponse(response => 
      response.url().includes('/api/v1/scenario/metadata/') && 
      response.request().method() === 'POST'
    );
    
    await page.click('[data-test="save-draft-btn"]');
    const saveResponse = await savePromise;
    expect(saveResponse.status()).toBe(200);
    
    // Verify Submit button enabled (if it was disabled)
    const submitBtn = page.locator('[data-test="submit-btn"]');
    await expect(submitBtn).toBeEnabled();

    // Submit for Approval intercept
    const submitPromise = page.waitForResponse(response => 
      response.url().includes('/submit') && 
      response.request().method() === 'POST'
    );
    
    await page.click('[data-test="submit-btn"]');
    const submitResponse = await submitPromise;
    expect(submitResponse.status()).toBe(200);
    
    await expect(page.locator('.ant-message-success')).toContainText(/submitted/i);
  });
});
