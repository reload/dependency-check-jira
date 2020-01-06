Feature: Run and parse dependency-checker output


  Scenario: When there's no issues
    Given the fixture "empty"
    When running
    Then it should succeed with output containing:
      """
      Running dependency-checker
      Done
      """

  Scenario: When there is issues
    Given the fixture "folly"
    When running
    Then it should succeed with output containing:
      """
      Running dependency-checker
      Done
      Detected CVE-2008-0660 on package Folly:2018.10.22.00 in /workspace/Folly.podspec
      Detected CVE-2019-11934 on package Folly:2018.10.22.00 in /workspace/Folly.podspec
      """
