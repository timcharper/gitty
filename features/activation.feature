Feature: activation
  As a developer that has recently cloned a project
  I want to activate the published shared hooks
  In order to use them
  
  Scenario: activation
    Given a recently cloned shared repository with published hooks
    When I run "git hook activate"
    And the repository should be gitty activated
  
  Scenario: automatic updating
    Given repository with activated shared hooks
    When I fetch new hooks that add the following to "post-checkout" as "touch_it_worked":
    """
      #!/bin/bash
      touch it_worked
    """
    And I switch to a new branch named "task_branch"
    Then the following files should exist:
    | it_worked |
    
  