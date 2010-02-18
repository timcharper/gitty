Feature: Initialization
  As a developer
  In order to use custom hooks in the git repository
  I want to initialize gitty for my repository
  
  Scenario: basic initialization
    Given that I have a git repository with some commits
    When I run "git hook init"

    Then the following folders should exist:
    | .git/hooks/shared |
    | .git/hooks/local  |

    And the following hooks are setup to run all shared and local hooks
    |applypatch-msg     |
    |pre-applypatch     |
    |post-applypatch    |
    |pre-commit         |
    |prepare-commit-msg |
    |commit-msg         |
    |post-commit        |
    |pre-rebase         |
    |post-checkout      |
    |post-merge         |
    |pre-auto-gc        |
