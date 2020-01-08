# dependency-check-jira

Runs [OWASP Dependency
Check](https://www.owasp.org/index.php/OWASP_Dependency_Check) using
the [CocoaPods
Analyser](https://jeremylong.github.io/DependencyCheck/analyzers/cocoapods.html)
and creates Jira tickets for any CVEs found.

Uses [Reload Security Issue
library](https://github.com/reload/jira-security-issue), which
requires the following environment variables:

- `JIRA_TOKEN`: A reference to the repo secret `JiraApiToken` (**REQUIRED**)
- `JIRA_HOST`: The endpoint for your Jira instance, e.g. https://foo.atlassian.net (**REQUIRED**)
- `JIRA_USER`: The ID of the Jira user which is associated with the 'JiraApiToken' secret, eg 'someuser@reload.dk' (**REQUIRED**)
- `JIRA_PROJECT`: The project key for the Jira project where issues should be created, eg `TEST` or `ABC`. (**REQUIRED**)
- `JIRA_ISSUE_TYPE`: Type of issue to create, e.g. `Security`. Defaults to `Bug`. (*Optional*)
- `JIRA_WATCHERS`: Jira users to add as watchers to tickets. Separate
  multiple watchers with comma (no spaces). (*Optional*)

## Options

Use `--dry-run` to run without actually creating issues, or
`--trial-run` to create a test issue in the given project.

## Development

There's both Behat and PHPUnit tests.

The Behat tests are slow as they build the image (not that slow,
actually) and run it in dry-run mode, which runs `dependency-checker`
(very slow), but it tests both the image and that `checkdep` parses
actual `dependency-checker` output.

PHPUnit tests are way faster, but only test specific parts.
