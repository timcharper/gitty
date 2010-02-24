Feature: managing hooks
  As a developer
  I want to manage installed hooks
  In order to use custom hooks in the git repository
  
  Background:
    Given I have a git repository initialized with gitty
    And the file "$GITTY_ASSETS/hooks/validation" contains:
      """
      #!/usr/bin/bash
      #
      # description: Validates you
      # version: 0.5
      # targets: ["post-commit"]
      # helpers: ["validator"]

      $GITTY_HELPERS/validator
      """
    And the file "$GITTY_ASSETS/helpers/validator" contains:
      """
      #!/usr/bin/bash
      
      echo "That is the greatest code I've ever seen written! You're amazing!"
      """
  Scenario: adding and removing a local hook
    When I run "git hook install --local validation"
    Then the following files should exist:
      | .git/hooks/local/hooks/validation         |
      | .git/hooks/local/post-commit.d/validation |
      | .git/hooks/local/helpers/validator        |
      
    When I run "git hook uninstall validation"
    Then the following files should not exist:
      | .git/hooks/local/post-commit.d/validation |
#      | .git/hooks/local/helpers/validator | - git hook cleanup type approach... TODO

  Scenario: adding and removing a shared hook
    When I run "git hook install --shared validation"
    Then the following files should exist:
      | .git/hooks/shared/post-commit.d/validation |
      | .git/hooks/shared/hooks/validation         |
      | .git/hooks/shared/helpers/validator        |
    And the output should contain "To propagate this change other developers, run 'git hook publish"

    When I run "git hook uninstall validation"
    Then the following files should not exist:
      | .git/hooks/shared/post-commit.d/validation |
      | .git/hooks/shared/hooks/validation         |
    And the output should contain "To propagate this change other developers, run 'git hook publish"

  Scenario: adding a hook that doesn't exist
    When I run "git hook install boogyman"
    Then the last exit status should be 1
    Then the error output should contain "no hook named 'boogyman' found"

  Scenario: removing a hook that hasn't been installed
    When I run "git hook uninstall validation"
    Then the last exit status should be 1
    Then the error output should contain "there is no installed hook named 'validation'"

#      | .git/hooks/shared/helpers/validator |

