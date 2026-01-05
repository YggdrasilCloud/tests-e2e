# Migration Guide

## Migrating Tests from Frontend Repository

### Step 1: Copy Test Files

Copy all test files from `frontend/tests/e2e/` to `tests-e2e/tests/`:

```bash
# From tests-e2e directory
cp -r ../frontend/tests/e2e/*.spec.ts ./tests/
```

Expected files:
- `folder-creation.spec.ts`
- `folders.spec.ts`
- `photos.spec.ts`
- `lightbox.spec.ts`

### Step 2: Update Imports (if needed)

Tests should already use relative imports, but verify:

```typescript
import { test, expect, type Page } from '@playwright/test';
```

No changes needed if tests already use this format.

### Step 3: Remove Tests from Frontend

Once migrated and verified, clean up frontend:

```bash
# In frontend/
rm -rf tests/e2e/
```

Update `frontend/package.json` to remove Playwright:

```json
{
  "scripts": {
    // Remove these:
    - "test:e2e": "playwright test",
    - "test:e2e:ui": "playwright test --ui"
  },
  "devDependencies": {
    // Remove:
    - "@playwright/test": "^1.40.0"
  }
}
```

### Step 4: Backend Seed Command

Create seed command in backend for test data.

#### Symfony Backend Example:

```php
// src/Command/SeedTestDataCommand.php
namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class SeedTestDataCommand extends Command
{
    protected static $defaultName = 'app:seed:test';

    private $entityManager;
    private $folderService;
    private $photoService;

    public function __construct($entityManager, $folderService, $photoService)
    {
        parent::__construct();
        $this->entityManager = $entityManager;
        $this->folderService = $folderService;
        $this->photoService = $photoService;
    }

    protected function configure(): void
    {
        $this->setDescription('Seeds test data for E2E tests');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        // Only allow in test environment
        if ($_ENV['APP_ENV'] !== 'test') {
            $output->writeln('<error>This command can only run in test environment</error>');
            return Command::FAILURE;
        }

        $output->writeln('<info>Purging database...</info>');
        // Truncate tables or use Doctrine fixtures

        $output->writeln('<info>Creating test owner...</info>');
        $ownerId = 'default-owner-uuid';

        $output->writeln('<info>Creating test folders...</info>');
        $folder1 = $this->folderService->createFolder('Test Folder 1', $ownerId);
        $folder2 = $this->folderService->createFolder('Test Folder 2', $ownerId);
        $folder3 = $this->folderService->createFolder('Empty Folder', $ownerId);

        $output->writeln('<info>Uploading test photos...</info>');
        $fixturesDir = '/app/fixtures/photos';

        if (is_dir($fixturesDir)) {
            $photos = glob("$fixturesDir/*.{jpg,jpeg,png,webp,gif}", GLOB_BRACE);

            foreach ($photos as $photoPath) {
                // Upload to first folder
                $this->photoService->uploadFromPath(
                    $folder1->getId(),
                    $photoPath,
                    basename($photoPath),
                    $ownerId
                );

                $output->writeln("  - Uploaded: " . basename($photoPath));
            }

            $output->writeln(sprintf('<info>Uploaded %d photos</info>', count($photos)));
        } else {
            $output->writeln('<comment>No fixtures directory found, skipping photo upload</comment>');
        }

        $output->writeln('<info>✅ Test data seeded successfully!</info>');
        return Command::SUCCESS;
    }
}
```

Register the command in `services.yaml`:

```yaml
services:
    App\Command\SeedTestDataCommand:
        tags:
            - { name: console.command }
```

Test it locally:

```bash
# In backend directory
docker compose exec backend php bin/console app:seed:test
```

### Step 5: Add Test Photo Fixtures

Add some test photos in `fixtures/photos/`:

Option A - Download from internet:

```bash
cd tests-e2e/fixtures/photos/
curl -o sample1.jpg "https://picsum.photos/800/600"
curl -o sample2.png "https://picsum.photos/1024/768"
curl -o sample3.webp "https://picsum.photos/640/480"
```

Option B - Use ImageMagick to create colored squares:

```bash
convert -size 800x600 xc:blue sample1.jpg
convert -size 1024x768 xc:green sample2.png
convert -size 640x480 xc:red sample3.webp
```

Option C - Use your own test photos (recommended):

```bash
# Copy some real photos for more realistic tests
cp ~/Pictures/vacation/*.jpg ./
```

### Step 6: Test Locally

```bash
# In tests-e2e/
npm install
npm run setup
npm run seed
npm test
```

Expected output:
```
✅ Database is ready!
🌱 Seeding test data...
✅ Test data seeded successfully!
🎭 Running E2E tests...

Running 185 tests using 8 workers
  81 passed
  0 failed
  104 skipped (no photos in some folders)
```

### Step 7: Update Frontend CI

Remove E2E tests from `frontend/.github/workflows/ci.yml`:

```yaml
# Remove this job:
- e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run E2E tests
        run: npm run test:e2e
```

Add trigger to tests-e2e instead:

```yaml
# Add at end of build job:
- name: Trigger E2E tests
  if: github.ref == 'refs/heads/main'
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.PAT_TOKEN }}
    repository: YggdrasilCloud/tests-e2e
    event-type: run-e2e
    client-payload: |
      {
        "frontend_version": "${{ github.sha }}",
        "backend_version": "latest"
      }
```

Do the same for backend CI.

### Step 8: Create PAT Token

For repository_dispatch to work, create a Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with scope: `repo` (Full control)
3. Add to backend repo secrets as `PAT_TOKEN`
4. Add to frontend repo secrets as `PAT_TOKEN`

### Step 9: Verify CI

Push a change to backend or frontend and verify:

1. Backend/Frontend CI builds Docker image
2. Triggers tests-e2e workflow
3. E2E tests run with latest images
4. Results appear in tests-e2e Actions tab

## Troubleshooting

### Tests fail with "No folders available"

**Cause**: Seed command didn't create folders

**Fix**: Check backend logs:
```bash
docker compose logs seed
```

Verify seed command works:
```bash
docker compose run --rm seed
```

### Photos don't appear in tests

**Cause**: No fixtures or seed command didn't upload them

**Fix**:
1. Add photos to `fixtures/photos/`
2. Verify seed command uploads them
3. Check backend logs for upload errors

### Port conflicts

**Cause**: Services already running on ports 5432, 8000, or 5173

**Fix**:
```bash
# Option 1: Stop conflicting services
docker ps
docker stop <container-id>

# Option 2: Change ports in compose.yaml
ports:
  - "5433:5432"  # Use different host port
```

## Rollback Plan

If migration causes issues:

1. Keep tests in frontend temporarily
2. Run both in parallel
3. Gradually migrate test by test
4. Only remove from frontend when 100% confident

## Benefits After Migration

✅ Clean separation of concerns
✅ Faster frontend CI (no E2E tests)
✅ E2E tests run against real Docker images
✅ Same environment locally and in CI
✅ Easy to test multiple backend/frontend versions
✅ Test data management centralized
✅ New developers only need Docker
