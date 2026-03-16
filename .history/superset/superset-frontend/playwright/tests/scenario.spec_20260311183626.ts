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
    // Use saved state for speed, but fall back to manual login if needed
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // 1. Navigate to the pre-configured chart (slice_id 2)
        await page.goto('explore/?slice_id=2');

        // 2. Wait for the page to load and ensure it's logged in
        // If we're redirected to login, the storageState might have expired
        if (page.url().includes('login')) {
            await page.locator('#username').fill('admin');
            await page.locator('#password').fill('general');
            await page.getByRole('button', { name: 'Sign In' }).click();
            await page.goto('explore/?slice_id=2');
        }

        // 3. Ensure the plugin container is visible
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 25000 });

        // 4. Verify data row presence (LNGC2 is a growth project)
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 15000 });

        // 5. Perform write-back on the first input in the LNGC2 row
        const cellInput = page.locator('tr:has-text("LNGC2") input').first();
        await expect(cellInput).toBeVisible();

        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        // Use a unique value for this run
        const testValue = (70 + Math.floor(Math.random() * 20)).toString();
        await cellInput.fill(testValue);
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);
        const result = await response.json();
        expect(result.status).toBe('success');

        // Final verification
        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue(testValue);
    });
});
