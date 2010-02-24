Feature: publishing hooks
  As a developer
  I want to publish shared hooks
  In order to synchronize local hooks amongst developers
  
  Background:
    Given I have a git repository initialized with gitty
    And the remote "origin" points to a bare repository at "$REMOTES_PATH/remote.git"
    And the file "$GITTY_ASSETS/hooks/validation" contains:
      """
      #!/bin/bash
      #
      # description: Validates you
      # version: 0.5
      # targets: ["post-commit"]
      # helpers: ["validator"]
      
      $HELPERS/validator
      """
    And the file "$GITTY_ASSETS/helpers/validator" contains:
      """
      #!/bin/bash
      
      echo "That is the greatest code I've ever seen written! You're amazing!"
      """

  Scenario: sharing hooks between repositories
    When I run "git hook install --shared validation"
    And I run "git hook publish -m 'added a validation hook to increase team morale'"
    Then the latest commit on origin/--hooks-- should contain "added a validation hook to increase team morale"
    
    When I clone "$REMOTES_PATH/remote.git" as "cloned"
    And I run "git hook init"
    And I run "echo content > README.txt"
    And I run "git add README.txt"
    And I run "git commit -m 'added a readme'"
    Then the error output should contain "That is the greatest code I've ever seen written! You're amazing!"
    
    When I run "git hook uninstall --shared validation"
    And I run "git hook publish -m 'Removed team morale booster.'"
    And I switch back to the original repository
    And I run "git fetch"
    And I run "echo more content >> README.txt"
    And I run "git commit -m 'added content to the readme' -a"
    Then the error output should not contain "That is the greatest code I've ever seen written! You're amazing!"
    
