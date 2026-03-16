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
    // We perform manual login to ensure a fresh session for this complex test
    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // 1. Manual Login
        await page.goto('login/');
        await page.locator('#username').fill('admin');
        await page.locator('#password').fill('general');
        await page.getByRole('button', { name: 'Sign In' }).click();
        await expect(page).toHaveURL(/.*welcome/, { timeout: 15000 });

        // 2. Navigate to Datasets list
        await page.goto('tablemodelview/list');

        // 3. Click on 'silver_scenario_equity_share'
        const datasetLink = page.locator('a:has-text("silver_scenario_equity_share")').first();
        await expect(datasetLink).toBeVisible({ timeout: 15000 });
        await datasetLink.click();

        // 4. We are now in Explore. Wait for stable load.
        await expect(page).toHaveURL(/.*explore/);

        // 5. Change Visualization Type to Scenario Creator
        // Find the Visualization Type control
        const vizTypeBtn = page.locator('[data-test="viz-type-control"]');
        await expect(vizTypeBtn).toBeVisible({ timeout: 15000 });
        await vizTypeBtn.click();

        // In the modal, search for Scenario
        const searchInput = page.locator('.ant-modal-content input[placeholder*="Search"]');
        await expect(searchInput).toBeVisible();
        await searchInput.fill('Scenario');
        await page.getByText('Scenario Creator').click();
        await page.getByRole('button', { name: 'Select', exact: true }).click();

        // 6. Add a Metric (COUNT(*)) if it's not already there
        const metricsControl = page.locator('[data-test="metrics"]');
        await expect(metricsControl).toBeVisible();
        await metricsControl.click();
        await page.keyboard.press('ArrowDown');
        await page.keyboard.press('Enter');

        // 7. Click Update Chart
        const updateBtn = page.getByRole('button', { name: /Update chart|Create chart/i });
        await updateBtn.click();

        // 8. Wait for the Scenario Plugin container
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 20000 });

        // 9. Verify data row presence (LNGC2)
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 15000 });

        // 10. Perform write-back
        // LNGC2 2020 should have 99 (or whatever was last successful)
        const cellInput = page.locator('tr:has-text("LNGC2") td').nth(2).locator('input');
        await expect(cellInput).toBeVisible();

        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Set a new value to trigger write-back
        const newValue = Math.floor(Math.random() * 100).toString();
        await cellInput.fill(newValue);
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Final verification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue(newValue);
    });
});
