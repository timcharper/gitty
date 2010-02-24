Feature:
  As a developer
  I want to list hooks
  In order to see what hooks are activated

  Background:
    Given I have a git repository initialized with gitty
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
    When I run "git hook install --shared validation"
    And I run "git hook install --local warning"
    And I run "git hook list"
    Then the output should contain
    """
    Listing hooks
    local:
    - warning

    shared:
    - validation

    uninstalled:
    """

  Scenario: listing uninstalled hooks doesn't include installed hooks
    When I run "git hook list --uninstalled"
    Then the output should contain "validation"

    When I run "git hook install validation"
    When I run "git hook list --uninstalled"
    Then the output should not contain "validation"
