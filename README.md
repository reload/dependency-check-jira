# dependency-check-jira

## Development

There's both Behat and PHPUnit tests.

The Behat tests are slow as they build the image (not that slow,
actually) and run it in dry-run mode, which runs `dependency-checker`
(very slow), but it tests both the image and that `checkdep` parses
actual `dependency-checker` output.

PHPUnit tests are way faster, but only test specific parts.
