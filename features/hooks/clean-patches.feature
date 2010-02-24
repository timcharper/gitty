Feature: clean-patches
  As a developer
  I want to have git help me to only commit clean patches
  In order to maintain my reputation as a good cooperator.

  Background:
    Given I have a git repository initialized with gitty
    And I run "git hook init"
    And I run "git hook install clean-patches"

  Scenario: prevents you from committing trailing whitespaces
    When I run:
    """
      echo "some code   " > app.rb
      git add app.rb
      git commit -m "adds app.rb"
    """
    Then the error output should contain "trailing whitespace"
    And the last exit status should be 1

    When I run "git diff --cached"
    Then the output should contain "some code"

  Scenario: prevents you from committing extra trailing newlines
    When I run:
    """
    echo "some code

    " > app.rb
    git add app.rb
    git commit -m "adds app.rb"
    """
    Then the error output should contain "new blank line at EOF"
    And the last exit status should be 1

    When I run "git diff --cached"
    Then the output should contain "some code"
