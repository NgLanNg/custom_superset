const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
  const page = await context.newPage();

  try {
    console.log('Logging in...');
    await page.goto('http://localhost:8088/login/');
    await page.waitForLoadState('networkidle');
    await page.locator('input[type="text"]').first().fill('admin');
    await page.locator('input[type="password"]').fill('admin');
    await page.click('button[type="submit"]');
    await page.waitForURL('http://localhost:8088/superset/welcome/');

    console.log('Loading dashboard...');
    await page.goto('http://localhost:8088/superset/dashboard/opu-ghg-summary/');
    await page.waitForSelector('.dashboard-component', { timeout: 15000 });
    await page.waitForTimeout(5000);

    // Check for errors
    const errors = await page.locator('[class*="error"], [class*="Error"]').allTextContents();
    const realErrors = errors.filter(e => e.includes('error') && !e.includes('flask-debug'));

    console.log(`\n=== DASHBOARD STATUS ===`);
    console.log(`Errors: ${realErrors.length}`);
    if (realErrors.length > 0) {
      realErrors.forEach(e => console.log(`  - ${e.substring(0, 200)}`));
    }

    // Count charts
    const charts = await page.locator('.chart-container').count();
    console.log(`Charts rendered: ${charts}`);

    // Take full page screenshot
    await page.screenshot({
      path: '/Users/alan/dashboard/tests/e2e/screenshots/dashboard-full.png',
      fullPage: true
    });
    console.log('\nScreenshot saved to: /Users/alan/dashboard/tests/e2e/screenshots/dashboard-full.png');

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await browser.close();
  }
})();