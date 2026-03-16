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
        // Navigate to Explore page with Scenario chart type and our dataset (ID 22)
        await page.goto('explore/?datasource_type=table&datasource_id=22&viz_type=scenario_chart');

        // If "Create chart" button is disabled, we need to select a metric to unblock it
        const createChartBtn = page.getByRole('button', { name: 'Create chart' });

        // Check if it's disabled. If so, select a metric.
        // In our manual debug, clicking the metrics zone and selecting COUNT(*) worked.
        const isReady = await createChartBtn.isEnabled();
        if (!isReady) {
            // Click metrics drop zone
            await page.locator('[data-test="metrics"]').click();
            // Select the first option (usually COUNT(*))
            await page.keyboard.press('ArrowDown');
            await page.keyboard.press('Enter');
            // Now click Create chart
            await createChartBtn.click();
        }

        // Wait for the chart container to be visible (using the styled-component class)
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 20000 });

        // Verify presence of specific elements from our plugin
        await expect(page.getByText('Equity Share Configuration')).toBeVisible();

        // Verify specific data (LNGC2 is a growth project from our SQL)
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 10000 });

        // Perform a write-back edit on LNGC2 2020 (index 2 in the row)
        const cellInput = page.locator('tr:has-text("LNGC2") td').nth(2).locator('input');
        await expect(cellInput).toBeVisible();

        // Setup response interception for the write-back API
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Change value and blur to trigger save
        await cellInput.fill('92');
        await cellInput.blur();

        // Verify API call was successful
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Verify success notification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('92');
    });
});
