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
 * specific language governing permissions and limitations
 * under the License.
 */

import { test, expect } from '@playwright/test';

test.describe('Scenario Plugin E2E', () => {
    // Use the pre-authenticated state from global-setup
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // Navigate to Explore page with Scenario chart type and our dataset (ID 22)
        // The dataset ID 22 corresponds to silver_scenario_equity_share
        await page.goto('explore/?dataset_type=table&dataset_id=22&viz_type=scenario_chart');

        // Wait for the chart container to be visible
        const container = page.locator('.superset-chart-scenario');
        await expect(container).toBeVisible({ timeout: 15000 });

        // Verify presence of specific elements from our plugin
        await expect(page.getByText('Equity Share Configuration')).toBeVisible();
        await expect(page.getByText('Source File Reference:')).toBeVisible();

        // Verify stats are calculated
        const totalAssets = page.locator('.stat-card').first();
        await expect(totalAssets.locator('.stat-value')).toContainText(/\d+/);

        // Verify the data from our SQL population is present (MLNG was inserted)
        await expect(page.getByText('MLNG')).toBeVisible();

        // Perform a write-back edit
        // MLNG in 2020 should have 70.0 (from populate_scenario_data.sql)
        const mlng2020Cell = page.locator('tr:has-text("MLNG") td').nth(2).locator('input');
        await expect(mlng2020Cell).toHaveValue('70');

        // Setup response interception for the write-back API
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Change value and blur to trigger save
        await mlng2020Cell.fill('75');
        await mlng2020Cell.blur();

        // Verify API call was successful
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Verify success notification
        await expect(page.getByText('Saved')).toBeVisible();

        // Verify the cell shows the changed state (style-based)
        // In our styles, $isChanged adds a background/border
        // We can't check the $isChanged attribute directly as it's a transient styled-component prop,
        // but we can check if it stays as '75'.
        await expect(mlng2020Cell).toHaveValue('75');
    });
});
