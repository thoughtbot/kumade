@creates-remote
Feature: Kumade executable
  As a user
  I want to be able to use the kumade executable
  So I can have a better experience than Rake provides

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    When I create a Heroku remote for "pretend-staging-app" named "pretend-staging"
    And I create a Heroku remote for "app-two" named "staging"

  Scenario: Pretend mode with a Heroku remote
    When I run `kumade deploy pretend-staging -p`
    Then the output should contain "In Pretend Mode"
    And the output should contain:
      """
      ==> Git repo is clean
      ==> Rake passed
      ==> Packaged assets with Jammit
      ==> Pushed master -> origin
      ==> Force pushed master -> pretend-staging
      ==> Migrated pretend-staging-app
      ==> Deployed to: pretend-staging
      """
    But the output should not contain "==> Packaged assets with More"

  Scenario: Default environment is staging
    When I run `kumade -p`
    Then the output should contain "==> Deployed to: staging"

  Scenario: Can deploy to arbitrary environment
    When I run `kumade deploy bamboo`
    Then the output should contain "==> Deploying to: bamboo"
    Then the output should match /Cannot deploy: /
