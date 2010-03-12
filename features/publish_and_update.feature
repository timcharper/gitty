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

  Scenario: sharing hooks between repositories is disabled by default
    When I run:
      """
        git hook share validation
        git hook publish -m 'added a validation hook to increase team morale'
      """
    Then the error output should contain "WARNING: sharing is disabled on your repository.  Run git hook init --enable-sharing to turn it on."
    Then the latest commit on origin/--hooks-- should contain "added a validation hook to increase team morale"
    And I switch to the directory "cloned"
    When I run:
    """
      git hook init --enable-sharing
      echo content > README
      git add README
      git commit -m 'added a readme'
    """
    Then the error output should not contain "That is the greatest code I've ever seen written! You're amazing!"

  Scenario: sharing hooks between repositories
    When I run:
      """
        git hook init --enable-sharing
        git hook share validation
        git hook publish -m 'added a validation hook to increase team morale'
      """
    Then the latest commit on origin/--hooks-- should contain "added a validation hook to increase team morale"
    
    When I clone "$REMOTES_PATH/remote.git" as "cloned"
    And I switch to the directory "cloned"
    When I run:
    """
      git hook init --enable-sharing
      echo content > README
      git add README
      git commit -m 'added a readme'
    """
    Then the error output should contain "That is the greatest code I've ever seen written! You're amazing!"
    
    When I run:
    """
      git hook uninstall validation
      git hook publish -m 'Removed team morale booster.'
    """
    And I switch to the directory "sandbox"
    And I run:
    """
      git fetch
      echo more content >> README
      pwd
      git commit -m 'added content to the readme' -a
    """
    Then the last exit status should be 0
    And the error output should contain "Hook updates were applied"
    And the error output should not contain "That is the greatest code I've ever seen written! You're amazing!"
    
