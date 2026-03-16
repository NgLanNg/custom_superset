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
        await page.goto(chartUrl);

        // 1. Handle Authentication Fallback
        if (page.url().includes('login')) {
            await page.locator('#username').fill('admin');
            await page.locator('#password').fill('general');
            await page.getByRole('button', { name: 'Sign In' }).click();
            await page.goto(chartUrl);
        }

        // 2. Handle "Keep control settings?" notification if it appears
        const continueBtn = page.getByRole('button', { name: 'Continue' });
        try {
            if (await continueBtn.isVisible({ timeout: 5000 })) {
                await continueBtn.click();
            }
        } catch (e) {
            // Ignore if not found
        }

        // 3. Wait for the plugin to render
        // We look for a unique title inside the plugin
        const pluginTitle = page.getByText('Equity Share Overview — Live Preview');
        await expect(pluginTitle).toBeVisible({ timeout: 60000 });

        // 4. Verify baseline data (MLNG is an existing asset)
        await expect(page.getByText('MLNG')).toBeVisible({ timeout: 15000 });

        // 5. Navigate to Growth Configuration Tab
        const growthTab = page.getByRole('tab', { name: 'Growth Configuration' });
        await growthTab.click();

        // 6. Verify growth project presence
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 15000 });

        // 7. Perform a write-back edit
        // Locate the first input cell in the LNGC2 row (Capacity MTPA)
        const growthRow = page.locator('tr').filter({ hasText: 'LNGC2' });
        const cellInput = growthRow.locator('input').first();

        await expect(cellInput).toBeVisible();

        // Capture the write-back API call
        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        const testValue = (10 + Math.floor(Math.random() * 5)).toString(); // e.g., 10-14
        await cellInput.fill(testValue);
        await cellInput.blur();

        // 8. Verify the write-back result
        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // 9. Verify UI feedback
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue(testValue);

        // 10. Switch back to Equity tab to see if chart updated (optional)
        await page.getByRole('tab', { name: 'Equity Share Configuration' }).click();
        await expect(pluginTitle).toBeVisible();
    });
});
