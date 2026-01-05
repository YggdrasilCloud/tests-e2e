# TODO: Complete E2E Infrastructure

## High Priority

### Backend Work

- [ ] Create `app:seed:test` command in Symfony
  - [ ] Purge test database
  - [ ] Create test owner/user
  - [ ] Create 3-5 test folders
  - [ ] Upload photos from `/app/fixtures/photos/`
  - [ ] Generate thumbnails
  - [ ] Add EXIF data if needed

- [ ] Add health check endpoint `/health` or `/api/health`
  - Return 200 OK when app is ready
  - Check database connection
  - Used by Docker healthcheck

### Tests-E2E Work

- [ ] Add test photo fixtures in `fixtures/photos/`
  - At least 3-5 sample images
  - Different formats: JPG, PNG, WebP
  - Different sizes
  - Consider using Git LFS for large files

- [ ] Copy tests from frontend
  ```bash
  cp ../frontend/tests/e2e/*.spec.ts ./tests/
  ```

- [ ] Install dependencies and verify locally
  ```bash
  npm install
  npm run setup
  npm run seed
  npm test
  ```

### Frontend Cleanup

- [ ] Remove E2E tests after migration verified
  ```bash
  rm -rf tests/e2e/
  ```

- [ ] Remove Playwright dependency from `package.json`

- [ ] Update CI workflow to trigger tests-e2e instead

## Medium Priority

### Documentation

- [ ] Add architecture diagram showing repos interaction
- [ ] Document seed data structure (folders, photos)
- [ ] Create video/GIF showing local workflow
- [ ] Add FAQ section to README

### CI/CD

- [ ] Create PAT token for repository_dispatch
- [ ] Add secrets to backend/frontend repos
- [ ] Test repository_dispatch triggers
- [ ] Add status badges to README

### Testing

- [ ] Verify all 81 active tests pass
- [ ] Fix skipped tests (104) by ensuring photos exist
- [ ] Add smoke test for each major feature
- [ ] Test on different environments (Linux, macOS, Windows)

## Low Priority

### Enhancements

- [ ] Add `compose.dev.yaml` override for volumes
  - Mount backend source for hot reload
  - Mount frontend source for hot reload

- [ ] Add test utilities/helpers
  - `createTestFolder()` helper
  - `uploadTestPhoto()` helper
  - `cleanupTestData()` helper

- [ ] Performance optimizations
  - Cache Playwright browsers in CI
  - Parallel test execution tuning
  - Database snapshots for faster reseeding

### Advanced Features

- [ ] Visual regression testing (Playwright screenshots)
- [ ] Accessibility testing (axe-core integration)
- [ ] Performance testing (Lighthouse CI)
- [ ] Load testing (k6 or Artillery)

## Optional Nice-to-Haves

- [ ] Dashboard for test results (Allure, ReportPortal)
- [ ] Slack/Discord notifications on test failures
- [ ] Automatic retry of flaky tests
- [ ] Test result trends over time
- [ ] Integration with project management (Linear, Jira)

## Verification Checklist

Before considering this complete:

- [ ] ✅ All tests pass locally
- [ ] ✅ All tests pass in CI
- [ ] ✅ Documentation is clear and complete
- [ ] ✅ New developers can run tests with one command
- [ ] ✅ Backend/Frontend CIs trigger E2E tests
- [ ] ✅ Zero tests skipped (all have test data)
- [ ] ✅ Test execution time < 5 minutes
- [ ] ✅ Failure screenshots/videos are helpful
- [ ] ✅ No flaky tests (consistent pass/fail)

## Success Metrics

- 🎯 100% E2E test pass rate
- ⚡ < 5 min total execution time
- 📊 0 flaky tests
- 🔄 Runs on every backend/frontend change
- 📝 Clear failure reports
- 🚀 Easy for new devs to run locally

## Questions to Resolve

- [ ] Should we version control test photos with Git LFS?
- [ ] Do we need separate seed data for different test scenarios?
- [ ] Should we test against multiple backend/frontend versions?
- [ ] How to handle test data cleanup between runs?
- [ ] Should we add API tests in addition to E2E?
