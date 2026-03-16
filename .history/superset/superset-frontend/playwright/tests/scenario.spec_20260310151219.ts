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
    test.use({ storageState: 'playwright/.auth/user.json' });

    test('should render Scenario chart and handle write-back', async ({ page }) => {
        // 1. Navigate directly to Explore with the right parameters
        await page.goto('explore/?datasource_type=table&datasource_id=22&viz_type=scenario_chart');

        // 2. Wait for the page to load
        await expect(page.getByText('Scenario Creator')).toBeVisible({ timeout: 15000 });

        // 3. Select Dimensions if needed to unblock "Create chart"
        // We try to click the Dimensions section and add 'bu'
        const dimensionsLabel = page.getByText('Dimensions', { exact: true });
        if (await dimensionsLabel.isVisible()) {
            await dimensionsLabel.click();
            await page.keyboard.type('bu');
            await page.keyboard.press('Enter');
            // Press Escape to close the popover if it stays open
            await page.keyboard.press('Escape');
        }

        // 4. Click Create chart / Update chart
        const createBtn = page.getByRole('button', { name: /Create chart|Update chart/i });
        if (await createBtn.isVisible()) {
            await createBtn.click();
        }

        // 5. Wait for the plugin to render
        const container = page.locator('div[class*="ScenarioContainer"]');
        await expect(container).toBeVisible({ timeout: 25000 });

        // 6. Verify data
        await expect(page.getByText('LNGC2')).toBeVisible({ timeout: 15000 });

        // 7. Test edit and write-back
        // We look for any input in a row containing LNGC2
        const cellInput = page.locator('tr:has-text("LNGC2") input').first();
        await expect(cellInput).toBeVisible();

        const writebackPromise = page.waitForResponse(response =>
            response.url().includes('/api/v1/scenario/writeback') &&
            response.request().method() === 'POST'
        );

        await cellInput.fill('77');
        await cellInput.blur();

        const response = await writebackPromise;
        expect(response.status()).toBe(200);

        await expect(page.getByText('Saved')).toBeVisible();
        await expect(cellInput).toHaveValue('77');
    });
});
