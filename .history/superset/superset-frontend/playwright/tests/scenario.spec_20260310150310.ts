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
        // Using datasource_type and datasource_id as required by the current Superset version
        await page.goto('explore/?datasource_type=table&datasource_id=22&viz_type=scenario_chart');

        // Wait for the chart container to be visible (using the styled-component class)
        // We search for elements with ScenarioContainer in the class list
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 15000 });

        // Verify presence of specific elements from our plugin
        await expect(page.getByText('Equity Share Configuration')).toBeVisible();
        await expect(page.getByText('Source File Reference:')).toBeVisible();

        // Verify stats are calculated
        const totalAssets = page.locator('div[class*="StatCard"]').first();
        await expect(totalAssets.locator('div[class*="stat-value"]')).toContainText(/\d+/);

        // Verify the data from our SQL population is present
        // It takes a moment for the data to load into the chart and tables
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 5000 });

        // Perform a write-back edit
        // LNGC2 2020 should have 50 (from populate_scenario_data.sql or mock)
        // We use the input fields in the table
        const cellInput = page.locator('tr:has-text("LNGC2") td').nth(2).locator('input');
        await expect(cellInput).toBeVisible();

        // Setup response interception for the write-back API
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Change value and blur to trigger save
        await cellInput.fill('88');
        await cellInput.blur();

        // Verify API call was successful
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Verify success notification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('88');
    });
});
