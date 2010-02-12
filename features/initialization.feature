Feature: Initialization
  In order to use custom hooks in the git repository
  As a developer
  I want to initialize gitty for my repository
  
  Scenario basic initialization
    Given that I have a git repository with some commits
    When I run "git hook init"
    Then the following folders should exist:
    | .git/hooks/shared |
    | .git/hooks/local  |
    And the repository should be gitty activated
