@slow
Feature: Kumade executable
  As a user
  I want to be able to use the kumade executable
  So I can have a better experience than Rake provides

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    And I set up the Gemfile with kumade
    And I add "jammit" to the Gemfile
    And I bundle
    When I set up a git repo
    And I create a Heroku remote named "pretend-staging"
    And I create a Heroku remote named "staging"
    And I create a non-Heroku remote named "bad-remote"

  Scenario: Pretend mode with a Heroku remote
    When I run kumade with "pretend-staging -p"
    Then the output should contain "In Pretend Mode"
    And the output should contain:
      """
      ==> Git repo is clean
      ==> Packaged with Kumade::JammitPackager
              git push origin master
      ==> Pushed master -> origin
              git branch deploy >/dev/null
              git push -f pretend-staging deploy:master
      ==> Pushed deploy:master -> pretend-staging
      ==> Migrated pretend-staging
      ==> Restarted pretend-staging
      ==> Deployed to: pretend-staging
      """

  Scenario: Default environment is staging
    When I run kumade with "-p"
    Then the output should contain "==> Deployed to: staging"

  Scenario: Deploying to an arbitrary environment fails
    When I run kumade with "bamboo"
    Then the output should contain "==> Deploying to: bamboo"
    And the output should match /Cannot deploy: /

  Scenario: Deploying to a non-Heroku remote fails
    When I run kumade with "bad-remote"
    Then the output should match /==> ! Cannot deploy: "bad-remote" remote does not point to Heroku/

  Scenario: Deploy from a branch that isn't "master"
    When I run `git checkout -b new_branch`
    And I run kumade with "pretend-staging -p"
    Then the output should contain "==> Pushed new_branch -> origin"
    And the output should contain "==> Deployed to: pretend-staging"
