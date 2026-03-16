/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 */

import { test, expect } from '@playwright/test';

test.describe('Scenario Plugin E2E', () => {
    // Use the pre-authenticated state from global-setup
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // 1. Navigate to Datasets list
        await page.goto('tablemodelview/list');

        // 2. Click on 'silver_scenario_equity_share'
        const datasetLink = page.locator('a:has-text("silver_scenario_equity_share")').first();
        await expect(datasetLink).toBeVisible({ timeout: 15000 });
        await datasetLink.click();

        // 3. We are now in Explore.
        await expect(page).toHaveURL(/.*explore/);

        // 4. Change Visualization Type to Scenario Creator
        // Find the current viz type button (default is usually Table)
        const vizTypeBtn = page.locator('.ant-card-head-title:has-text("Visualization Type")').locator('..').locator('..');
        // Actually, easier to find the button with the current viz name
        const changeVizBtn = page.locator('[data-test="viz-type-control"]');
        await expect(changeVizBtn).toBeVisible({ timeout: 10000 });
        await changeVizBtn.click();

        // In the modal, search for Scenario
        const searchInput = page.locator('.ant-modal-content input[placeholder*="Search"]');
        await expect(searchInput).toBeVisible();
        await searchInput.fill('Scenario');
        await page.getByText('Scenario Creator').click();
        await page.getByRole('button', { name: 'Select', exact: true }).click();

        // 5. Add a Metric (COUNT(*))
        const metricsControl = page.locator('[data-test="metrics"]');
        await expect(metricsControl).toBeVisible();
        await metricsControl.click();
        // Select the first metric
        await page.keyboard.press('ArrowDown');
        await page.keyboard.press('Enter');

        // 6. Click Update Chart
        const updateBtn = page.getByRole('button', { name: 'Update chart' }).or(page.getByRole('button', { name: 'Create chart' }));
        await updateBtn.click();

        // 7. Wait for the Scenario Plugin container
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 20000 });

        // 8. Verify data row presence (LNGC2)
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 10000 });

        // 9. Perform write-back
        const cellInput = page.locator('tr:has-text("LNGC2") td').nth(2).locator('input');
        await expect(cellInput).toBeVisible();

        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        await cellInput.fill('99');
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Final verification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('99');
    });
});
