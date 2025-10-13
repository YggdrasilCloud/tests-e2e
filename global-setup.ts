import { chromium, FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
	const baseURL = config.use?.baseURL || 'http://localhost:5174';

	console.log('🔍 Waiting for application to be ready...');
	console.log(`   Base URL: ${baseURL}`);

	const browser = await chromium.launch();
	const context = await browser.newContext();
	const page = await context.newPage();

	// Wait up to 60 seconds for the frontend to respond
	let ready = false;
	const maxAttempts = 60;

	for (let i = 0; i < maxAttempts; i++) {
		try {
			const response = await page.goto(baseURL, { timeout: 2000, waitUntil: 'domcontentloaded' });

			if (response && response.ok()) {
				console.log('✅ Application is ready!');
				ready = true;
				break;
			}
		} catch (error) {
			// Retry
			await new Promise((resolve) => setTimeout(resolve, 1000));
		}
	}

	await browser.close();

	if (!ready) {
		throw new Error(
			`❌ Application not ready after ${maxAttempts} seconds. Make sure services are running:\n` +
				`   - Database: docker compose up -d db\n` +
				`   - Backend: running on http://localhost:8000\n` +
				`   - Frontend: running on ${baseURL}\n` +
				`   - Seed data: ./scripts/seed.sh`
		);
	}
}

export default globalSetup;
