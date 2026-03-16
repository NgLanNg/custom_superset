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
        // 1. Start from Datasets list to ensure stable session and datasource mapping
        await page.goto('tablemodelview/list');

        // 2. Locate and click on 'silver_scenario_equity_share'
        const datasetLink = page.getByRole('link', { name: 'silver_scenario_equity_share' });
        await expect(datasetLink).toBeVisible({ timeout: 15000 });
        await datasetLink.click();

        // 3. We are now in Explore. Switch to Scenario Creator if it's not the default
        await expect(page).toHaveURL(/.*explore/);

        // Click on visualization type to change it
        // The current viz type is shown in a button/div
        const vizTypeControl = page.locator('.viz_type-control'); // This is a common class in Superset
        // If we can't find it, we look for the text of current viz (likely Table)
        const currentViz = page.getByRole('button', { name: /Table|Line Chart|Bar Chart/i });
        if (await currentViz.isVisible()) {
            await currentViz.click();
            // Search for Scenario Creator in the modal
            await page.locator('.ant-modal-content input[placeholder*="Search"]').fill('Scenario');
            await page.getByText('Scenario Creator').click();
            await page.getByRole('button', { name: 'Select', exact: true }).click();
        }

        // 4. Ensure the control panel is loaded
        await expect(page.getByText('Scenario Creator')).toBeVisible({ timeout: 15000 });

        // 5. Select a metric if "Create chart" is disabled
        const createChartBtn = page.getByRole('button', { name: 'Create chart' });
        if (await createChartBtn.isDisabled()) {
            await page.locator('[data-test="metrics"]').click();
            // Wait for popover or search
            await page.keyboard.press('ArrowDown');
            await page.keyboard.press('Enter');
            await createChartBtn.click();
        }

        // 6. Wait for the Scenario Plugin container
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 20000 });

        // 7. Verify data row presence (LNGC2 is in our SQL)
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 10000 });

        // 8. Perform write-back
        const cellInput = page.locator('tr:has-text("LNGC2") td').nth(2).locator('input');
        await expect(cellInput).toBeVisible();

        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        await cellInput.fill('98');
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Final verification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('98');
    });
});
