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
        // 1. Navigate to Welcome page first to verify session is active
        await page.goto('superset/welcome/');
        await expect(page).toHaveURL(/.*welcome/);

        // 2. Navigate to Explore page with Scenario chart type and dataset (ID 22)
        // Usingdatasource_type=table and datasource_id=22
        await page.goto('explore/?datasource_type=table&datasource_id=22&viz_type=scenario_chart');

        // 3. Handle potential "Missing dataset" error by reloading or clicking "Swap dataset" if it appears
        // Sometimes Superset needs a moment to initialize the datasource context
        const missingDatasetAlert = page.getByText('Missing dataset');
        if (await missingDatasetAlert.isVisible({ timeout: 5000 }).catch(() => false)) {
            await page.reload();
        }

        // 4. Ensure the control panel is loaded
        await expect(page.getByText('Scenario Creator')).toBeVisible({ timeout: 15000 });

        // 5. Select a metric if "Create chart" is disabled
        const createChartBtn = page.getByRole('button', { name: 'Create chart' });
        if (await createChartBtn.isDisabled()) {
            // Click metrics drop zone. Selectors in Superset can be tricky.
            // We look for the "Metrics" label or the plus icon in that section.
            await page.locator('[data-test="metrics"]').click();
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

        await cellInput.fill('95');
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Final verification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('95');
    });
});
