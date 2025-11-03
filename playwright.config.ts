import { defineConfig, devices } from '@playwright/test';

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
	testDir: './frontend-submodule/tests/e2e',
	// Temporarily skip infinite-scroll tests while investigating timeout issues
	testIgnore: '**/infinite-scroll*.spec.ts',
	fullyParallel: true,
	forbidOnly: !!process.env.CI,
	retries: process.env.CI ? 2 : 0,
	workers: process.env.CI ? 4 : undefined,
	reporter: [
		['html', { outputFolder: 'playwright-report' }],
		['junit', { outputFile: 'test-results/junit.xml' }],
		['list']
	],

	use: {
		baseURL: process.env.BASE_URL || 'http://localhost:5174',
		trace: 'on-first-retry',
		screenshot: 'only-on-failure',
		video: 'retain-on-failure'
	},

	projects: [
		{
			name: 'chromium',
			use: { ...devices['Desktop Chrome'] }
		},
		{
			name: 'firefox',
			use: { ...devices['Desktop Firefox'] }
		},
		{
			name: 'webkit',
			use: { ...devices['Desktop Safari'] }
		},
		{
			name: 'Mobile Chrome',
			use: { ...devices['Pixel 5'] }
		},
		{
			name: 'Mobile Safari',
			use: { ...devices['iPhone 12'] }
		}
	],

	globalSetup: require.resolve('./global-setup.ts')
});
