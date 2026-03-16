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
    // Use saved state for speed
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // Increase timeout for this complex chart
        test.slow();

        const chartUrl = 'explore/?slice_id=2';

        // 1. Navigate and handle auth
        await page.goto(chartUrl);

        // 2. Auth fallback (sometimes storageState is not picked up correctly)
        if (page.url().includes('login')) {
            await page.locator('#username').fill('admin');
            await page.locator('#password').fill('general');
            await page.getByRole('button', { name: 'Sign In' }).click();
            await page.goto(chartUrl);
        }

        // 3. Handle potential Superset modals/notifications
        // Specifically "Keep control settings?" or "Dataset changed"
        const continueBtn = page.getByRole('button', { name: 'Continue' });
        if (await continueBtn.isVisible({ timeout: 10000 })) {
            await continueBtn.click();
        }

        // 4. Wait for the plugin container 
        // We use getByTestId for the container we just instrumented
        const container = page.getByTestId('scenario-chart-container');
        await expect(container).toBeVisible({ timeout: 60000 });

        // 5. Verify chart title is visible
        const title = page.getByTestId('chart-title');
        await expect(title).toContainText('Equity Share Overview');

        // 6. Verify data row presence in the first table
        const existingTable = page.getByTestId('existing-assets-table');
        await expect(existingTable.getByText('MLNG')).toBeVisible({ timeout: 15000 });

        // 7. Navigate to Growth Configuration Tab
        const growthTab = page.getByRole('tab', { name: 'Growth Configuration' });
        await growthTab.click();

        // 8. Verify growth project presence in the pipeline table
        const pipelineTable = page.getByTestId('growth-pipeline-table');
        await expect(pipelineTable.getByText('LNGC2')).toBeVisible({ timeout: 15000 });

        // 9. Perform a write-back edit
        // Locate the first input cell in the LNGC2 row (FID Year or Capacity)
        const growthRow = pipelineTable.locator('tr').filter({ hasText: 'LNGC2' });
        const cellInput = growthRow.locator('input').first();

        await expect(cellInput).toBeVisible();

        // Capture the write-back API call
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        const testValue = (2025 + Math.floor(Math.random() * 5)).toString(); // 2025-2029
        await cellInput.fill(testValue);
        await cellInput.blur();

        // 10. Verify the write-back result
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // 11. Verify UI feedback
        // The "Saved" notification usually appears on success
        await expect(page.getByText('Saved')).toBeVisible({ timeout: 10000 });
        await expect(cellInput).toHaveValue(testValue);
    });
});
