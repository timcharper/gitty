Feature:
  As a developer
  I want to show a hook
  In order to see what it does

  Background:
    Given I have a git repository initialized with gitty
    And the file "$GITTY_ASSETS/hooks/validation" contains:
      """
      #!/bin/bash
      # description: Validates you
      # version: 0.4
      # targets: ["post-commit", "pre-commit"]

      echo "You are awesome"
      """

  Scenario: show details of an uninstalled hook
    When I run "git hook show validation"
    Then the output should contain
    """
    Hook 'validation' is not installed

    DESCRIPTION:
    Validates you

    version: 0.4
    targets: post-commit, pre-commit
    """

  Scenario: show details of an installed hook
    When I run "git hook install validation"
    And I run "git hook show validation"
    Then the output should contain "Hook 'validation' is installed"
