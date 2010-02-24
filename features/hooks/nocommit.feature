Feature: nocommit
  As a developer
  I want to tag code as NOCOMMIT
  In order to prevent me from committing debug code

  Background:
    Given I have a git repository initialized with gitty
    And I run "git hook init"
    And I run "git hook install nocommit"

  Scenario: nocommit stops you from committing NOCOMMIT
    When I run:
    """
      echo "This is some debug code # NOCOMMIT" > app.rb
      git add app.rb
      git commit -m "adds app.rb"
    """
    Then the error output should contain "You tried to commit a line containing NOCOMMIT"
    And the last exit status should be 1

    When I run "git diff --cached"
    Then the output should contain "This is some debug code # NOCOMMIT"

  Scenario: normal code goes through
    When I run:
    """
      echo "This is some production code" > app.rb
      git add app.rb
      git commit -m "adds app.rb"
    """
    Then the error output should not contain "You tried to commit a line containing NOCOMMIT"
    And the last exit status should be 0
