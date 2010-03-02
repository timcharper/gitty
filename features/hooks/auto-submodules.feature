Feature: auto submodules
  As a developer
  I want to automatically update submodules when I switch branches
  In order to remove the mundane process of managing them
  
  Background:
    Given I have a git repository initialized with gitty
    And I run "git hook init"
    And I run "git hook install auto-submodules"
    When I run:
    """
      (mkdir -p ../submodule.git && cd ../submodule.git && git init --bare)
      (mkdir -p ../superproj.git && cd ../superproj.git && git init --bare)
      git remote add origin ../superproj.git
      git push origin master
      
      mkdir submod
      cd submod
        git init
        echo submodule README contents > README
        git add README
        git commit -m "added submodule README"
        git remote add origin ../../submodule.git
        git push origin master
      cd ..
      ../../assets/helpers/git-submodule-helper add-folder submod
      git commit -m "added submodule"
    """
    Then the following files should exist:
      | .gitmodules |

  Scenario: auto-update
    
    When I run:
    """
      git checkout -b super_project_next
      cd submod
        git checkout -b submodule_next
        echo more README contents >> README
        git commit -m 'more submodule README contents' -a
      cd ..
      git commit -m "bump submodule" -a
    """
    Then the file ".git/HEAD" should include "ref: refs/heads/super_project_next"
    Then the file "submod/.git/HEAD" should include "ref: refs/heads/submodule_next"
    
    When I run "git checkout master"
    
    Then the file ".git/HEAD" should include "ref: refs/heads/master"
    And the file "submod/.git/HEAD" should include "ref: refs/heads/master"

    # Test auto-fastforward
    When I run:
    """
      cd submod
        git push origin submodule_next:submodule_next
        git branch submodule_next master -f
      cd ..
      git checkout super_project_next
    """
    Then the file ".git/HEAD" should include "ref: refs/heads/super_project_next"
    Then the file "submod/.git/HEAD" should include "ref: refs/heads/submodule_next"

  Scenario: rebasing should leave the submodule alone (until git post-rebase is available)
    When I run:
    """
      git checkout -b super_project_next
      cd submod
        git checkout -b submodule_next
        echo more README contents >> README
        git commit -m 'more submodule README contents' -a
      cd ..
      git commit -m "bump submodule" -a

      git checkout master
      echo more changes >> README
      git add README && git commit -m "more changes to readme"

      git checkout super_project_next
      git rebase master
    """
    Then the file "submod/.git/HEAD" should include "ref: refs/heads/submodule_next"
