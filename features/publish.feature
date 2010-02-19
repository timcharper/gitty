Feature: publishing hooks
  As a developer
  I want to publish shared hooks
  In order to synchronize local hooks amongst developers
  
  Background:
    Given I have a git repository activated with gitty
    And the remote "origin" points to a bare repository at "$REMOTES_PATH/remote.git"
    And the file "$GITTY_ASSETS/hooks/validation" contains:
      """
      #!/usr/bin/bash
      #
      # description: Validates you
      # version: 0.5
      # targets: ["post-commit"]
      # helpers: ["validator"]
      """
    And the file "$GITTY_ASSETS/helpers/validator" contains:
      """
      #!/usr/bin/bash
      
      echo "That is the greatest code I've ever seen written! You're amazing!"
      """

  Scenario: publishing a shared hook
    When I run "git hook add --shared validation"
    And I run "git hook publish -m 'added a validation hook to increase team morale'"
    Then the latest commit on origin/--hooks-- should contain "added a validation hook to increase team morale"
