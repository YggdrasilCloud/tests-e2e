# Release Workflow Documentation

## Overview

This document describes the automated release workflow for YggdrasilCloud using E2E tests to validate releases before tagging.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Release Workflow                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Developer triggers pre-release workflow in core/frontend     │
│  2. Quality checks run (lint, tests, build)                      │
│  3. Resolve counterpart version (latest stable tag)              │
│  4. Trigger E2E tests in tests-e2e repo                          │
│  5. Wait for E2E tests to pass                                   │
│  6. Create Git tag + GitHub Release                              │
│  7. [Optional] Post-tag verification                             │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Release Scenarios

### Scenario 1: Release Core v2.0.0

```bash
# Trigger from GitHub UI or CLI
gh workflow run pre-release.yml \
  -f version=v2.0.0 \
  -f dry_run=false \
  -R YggdrasilCloud/core
```

**What happens:**
1. ✅ Run quality checks on `core:main`
2. ✅ Resolve latest stable frontend tag (e.g., `v1.5.0`)
3. ✅ Trigger E2E with `core:main` + `frontend:v1.5.0`
4. ⏳ Wait for E2E tests
5. ✅ Create tag `v2.0.0` on core
6. ✅ Verify with `core:v2.0.0` + `frontend:v1.5.0`

### Scenario 2: Release Frontend v1.6.0

```bash
gh workflow run pre-release.yml \
  -f version=v1.6.0 \
  -f dry_run=false \
  -R YggdrasilCloud/frontend
```

**What happens:**
1. ✅ Build and test `frontend:main`
2. ✅ Resolve latest stable core tag (e.g., `v2.0.0`)
3. ✅ Trigger E2E with `core:v2.0.0` + `frontend:main`
4. ⏳ Wait for E2E tests
5. ✅ Create tag `v1.6.0` on frontend
6. ✅ Verify with `core:v2.0.0` + `frontend:v1.6.0`

## Workflow Inputs

### `version` (required)
The version to create (e.g., `v1.2.3`)
- Must follow semver format
- Will be used as Git tag name

### `dry_run` (optional, default: false)
If `true`, executes all steps except tag/release creation.
- Useful for testing the workflow
- E2E tests still run
- No Git tag is created

### `include_prereleases` (optional, default: false)
If `true`, includes pre-releases when resolving counterpart version.
- By default, only stable releases are considered
- Pre-releases have `-` in version (e.g., `v1.0.0-alpha`)

## E2E Test Configuration

### Environment Variables

The E2E workflow uses a `.env` file to specify versions:

```bash
CORE_VERSION=main          # or v2.0.0, commit SHA
FRONTEND_VERSION=v1.5.0    # or main, commit SHA
```

### Docker Compose Files

- `docker-compose.yml` - Base configuration with builds
- `docker-compose.ci.yml` - CI override using Docker images
- `docker-compose.override.yml` - Local dev override (gitignored)

### Usage in CI

```bash
# Create .env file
echo "CORE_VERSION=main" > .env
echo "FRONTEND_VERSION=v1.5.0" >> .env

# Start services with CI config
docker compose -f docker-compose.yml -f docker-compose.ci.yml up -d

# Run E2E tests
npm run test:e2e
```

## Semver Filtering

By default, pre-releases are excluded when resolving versions:

**Included:**
- `v1.0.0`
- `v2.3.1`

**Excluded (by default):**
- `v1.0.0-alpha`
- `v2.0.0-beta.1`
- `v1.5.0-rc.2`

To include pre-releases, set `include_prereleases: true`.

## Artifacts

Each E2E run generates a metadata artifact:

```json
{
  "core_ref": "main",
  "core_sha": "abc123...",
  "frontend_ref": "v1.5.0",
  "frontend_sha": "def456...",
  "triggered_by": "core",
  "target_version": "v2.0.0",
  "dry_run": false,
  "verification_type": "",
  "timestamp": "2025-10-12T00:15:30Z",
  "workflow_run_id": "123456789",
  "e2e_result": "success"
}
```

Find artifacts in: Actions → E2E Tests → Artifacts

## Post-Tag Verification

After creating a tag, a final E2E verification runs with the new tag + counterpart stable version.

**Deduplication:** If the exact same version pair was already tested successfully in the last 24h, the verification is skipped.

## Troubleshooting

### E2E tests fail

1. Check E2E workflow logs: https://github.com/YggdrasilCloud/tests-e2e/actions
2. Download artifacts to see detailed test results
3. If needed, fix issues and re-run with `dry_run: true`

### Can't find latest version

- Ensure the counterpart repo has at least one release
- Check if you need `include_prereleases: true`
- Verify GitHub token has read access

### Services not ready

- Check Docker images are built and published
- Verify `docker-compose.ci.yml` uses correct image names
- Check health check endpoints are correct

## Local Testing

Test the E2E workflow locally:

```bash
# Clone repos
cd tests-e2e

# Create .env
echo "CORE_VERSION=main" > .env
echo "FRONTEND_VERSION=main" >> .env

# Use local override (builds from source)
docker compose up -d

# Run tests
npm run test:e2e
```

## Required Secrets

### Core and Frontend repos
- `GH_PAT` - GitHub Personal Access Token with:
  - `repo` scope (full control)
  - `workflow` scope (trigger workflows)

### tests-e2e repo
- `GH_PAT` - Same token to report status back

## Best Practices

1. **Always dry-run first**
   ```bash
   gh workflow run pre-release.yml -f version=v1.0.0 -f dry_run=true
   ```

2. **Check E2E logs before releasing**

3. **Use semver correctly**
   - MAJOR: Breaking changes
   - MINOR: New features (backward-compatible)
   - PATCH: Bug fixes

4. **Don't skip post-tag verification**
   - Ensures the tagged versions work together

5. **Monitor E2E test duration**
   - If tests take too long, optimize them
   - Consider parallel execution

## Workflow Files

- `core/.github/workflows/pre-release.yml`
- `frontend/.github/workflows/pre-release.yml`
- `tests-e2e/.github/workflows/e2e-tests.yml`
