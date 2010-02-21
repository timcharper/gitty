Feature:
  As a developer
  I want to list hooks
  In order to see what hooks are activated

  Background:
    Given I have a git repository initialized with gitty
    And the remote "origin" points to a bare repository at "$REMOTES_PATH/remote.git"
    And the file "$GITTY_ASSETS/hooks/validation" contains:
      """
      #!/bin/bash
      # description: Validates you
      # targets: ["post-commit", "pre-commit"]

      echo "You are awesome"
      """
    And the file "$GITTY_ASSETS/hooks/warning" contains:
      """
      #!/bin/bash
      # description: Warns you about potential bug
      # targets: ["post-commit", "pre-commit"]

      echo "Warning! Programming is known to induce bugs into software, are you sure you want to proceed?"
      exit 1
      """

  Scenario: listing all hooks
    When I run "git hook add --shared validation"
    And I run "git hook add --local warning"
    And I run "git hook list"
    Then the output should contain
    """
    Listing hooks
    local:
    - warning

    shared:
    - validation

    available:
    """

  Scenario: listing available hooks doesn't include activated hooks
    When I run "git hook list --available"
    Then the output should contain "validation"

    When I run "git hook add validation"
    When I run "git hook list --available"
    Then the output should not contain "validation"
