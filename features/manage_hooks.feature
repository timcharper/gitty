Feature: managing hooks
  As a developer
  I want to manage installed hooks
  In order to use custom hooks in the git repository
  
  Background
    Given that I have a git repository activated with gitty
    And the file "$GITTY_HOME/hooks/validation" with:
      """
      #!/usr/bin/bash
      #
      # description: Validates you
      # version: 0.5
      # targets: ["post-commit"]
      # helpers: ["validator"]
      """
    And the file "$GITTY_HOME/helpers/validator" with:
      """
      #!/usr/bin/bash
      
      echo "That is the greatest code I've ever seen written! You're amazing!"
      """
  Scenario adding and removing a local hook
    When I run "git hook add --local validation"
    Then the following files should exist:
      | .git/hooks/local/post-commit.d/validation |
      | .git/hooks/local/helpers/validator |
      
    When I run "git hook remove --local validation"
    Then the following files should not exist:
      | .git/hooks/local/post-commit.d/validation |
      | .git/hooks/local/helpers/validator |

  Scenario adding and removing a shared hook
    When I run "git hook add --shared validation"
    Then the following files should exist:
      | .git/hooks/shared/post-commit.d/validation |
      | .git/hooks/shared/helpers/validator |
      
    When I run "git hook remove --shared validation"
    Then the following files should not exist:
      | .git/hooks/shared/post-commit.d/validation |
      | .git/hooks/shared/helpers/validator |

