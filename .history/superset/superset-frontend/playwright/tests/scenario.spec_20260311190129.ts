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
    // Use saved storage state for session persistence
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // This is a heavy chart with multiple data requests, use slower timeout
        test.slow();

        const chartUrl = 'explore/?slice_id=2';

        // 1. Navigate to the chart
        await page.goto(chartUrl);

        // 2. Handle Authentication Fallback
        // Sometimes the storage state might expire or not be picked up
        if (page.url().includes('login')) {
            await page.locator('#username').fill('admin');
            await page.locator('#password').fill('general');
            await page.getByRole('button', { name: 'Sign In' }).click();
            await page.goto(chartUrl);
        }

        // 3. Handle Superset "Keep control settings?" popover
        // This appears if the previous session had unsaved changes
        const continueBtn = page.getByRole('button', { name: 'Continue' });
        if (await continueBtn.isVisible({ timeout: 8000 })) {
            await continueBtn.click();
        }

        // 4. Wait for the Scenario Chart container to be visible
        // We use a partial class selector for robustness against emotion hashed classes
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 60000 });

        // 5. Verify the internal title exists within the plugin
        const pluginTitle = page.getByText('Equity Share Overview — Live Preview');
        await expect(pluginTitle).toBeVisible({ timeout: 20000 });

        // 6. Navigate to "Growth Configuration" Tab
        // Ant Design Tabs use role="tab"
        const growthTab = page.getByRole('tab', { name: 'Growth Configuration' });
        await growthTab.click();

        // 7. Verify growth project presence (LNGC2 is a known growth project)
        const growthProject = page.getByText('LNGC2');
        await expect(growthProject).toBeVisible({ timeout: 15000 });

        // 8. Perform a Write-back Edit
        // Locate the first editable input in the LNGC2 row
        // Growth row is inside a table, we filter for the row containing project name
        const row = page.locator('tr').filter({ hasText: 'LNGC2' });
        const cellInput = row.locator('input').first();

        await expect(cellInput).toBeVisible();

        // Prepare to capture the write-back API call
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Enter a new value and blur to trigger save
        const newValue = (2025 + Math.floor(Math.random() * 5)).toString();
        await cellInput.fill(newValue);
        await cellInput.blur();

        // 9. Verify the API response
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // 10. Verify UI Feedback
        // The "Saved" notification toast appears on success
        await expect(page.getByText('Saved')).toBeVisible({ timeout: 10000 });
        await expect(cellInput).toHaveValue(newValue);
    });
});
