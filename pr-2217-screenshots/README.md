# App Center PR #2217 screenshots

These PNGs are unedited headless Flutter renders of the actual LocalDebPage widget, using the Yaru light theme and Ubuntu font. PackageKit responses are mocked with the project's existing test helpers. They are not screenshots of a running Ubuntu desktop or evidence of a real PackageKit install/downgrade.

PR head: 55d3940b. Flutter: 3.44.9. Size: 1000 × 720 at device-pixel-ratio 1. All screenshots open the test fixture testdeb version 1.0.

| File | Installed version in fixture | Rendered action |
|---|---|---|
| before-local-1.0-installed-0.9.png | 0.9, before patch | Installed, disabled |
| after-local-1.0-installed-0.9.png | 0.9, with patch | Install, enabled |
| after-local-1.0-installed-1.0.png | 1.0, with patch | Installed, disabled |
| after-local-1.0-installed-1.1.png | 1.1, with patch | Install, enabled: older local file |
| after-confirmation-dialog.png | 0.9, with patch | Existing confirmation dialog after clicking Install |

Installed version is fixture input and is not displayed by the page itself. The version shown in the screenshots is the local file version.

Validation: after captures plus existing local_deb_page_test.dart: 8 tests passed. Before capture: 1 test passed, using the pre-patch production model from the parent commit, then restoring the exact current file in a finally block. Expected enabled/disabled state is asserted before each PNG is written. All images were visually inspected where relevant (before, after, dialog).

The screenshot harness is preserved here for reproducibility. To rerun the after captures, temporarily copy pr_2217_screenshot_test.dart into packages/app_center/test in the checkout, run flutter test test/pr_2217_screenshot_test.dart --no-pub, then remove the temporary copy. The output path in the harness is specific to this workspace. The before capture additionally requires temporarily using the pre-patch production model and SCREENSHOT_BASELINE=true; restore the model afterward.

No application code was changed and no screenshot or reply was posted to GitHub.
