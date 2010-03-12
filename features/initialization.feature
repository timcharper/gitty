Feature: Initialization
  As a developer
  In order to use custom hooks in the git repository
  I want to initialize gitty for my repository
  
  Scenario: basic initialization
    Given I have a git repository with some commits
    When I run "git hook init"

    Then the following folders should exist:
    | .git/hooks/shared |
    | .git/hooks/local  |

    And the following hooks are setup to run all shared and local hooks
    | applypatch-msg     |
    | pre-applypatch     |
    | post-applypatch    |
    | pre-commit         |
    | prepare-commit-msg |
    | commit-msg         |
    | post-commit        |
    | pre-rebase         |
    | post-checkout      |
    | post-merge         |
    | pre-auto-gc        |

  Scenario: initialization in a repo that already has hooks
    Given I have a git repository with some commits
    And the file ".git/hooks/post-commit" contains:
      """
      echo "You are awesome"
      """
    When I run "git hook init"
    Then the following folders should exist:
    | .git/hooks/local/post-commit.d/original |
