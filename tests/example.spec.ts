import { test, expect } from '@playwright/test';

/**
 * Example E2E test
 *
 * This is a simple smoke test to verify the test infrastructure works.
 * Real tests should be migrated from frontend/tests/e2e/
 */

test.describe('Smoke Tests', () => {
	test('should load the homepage', async ({ page }) => {
		await page.goto('/photos');
		await page.waitForLoadState('networkidle');

		// Should show the main heading
		await expect(page.locator('h1')).toBeVisible();

		// Should have "New Folder" button
		await expect(page.getByRole('button', { name: /new folder/i })).toBeVisible();
	});

	test('should have working navigation', async ({ page }) => {
		await page.goto('/photos');
		await page.waitForLoadState('networkidle');

		// Navigation should be present
		const nav = page.locator('nav, aside');
		await expect(nav).toBeVisible();
	});
});
