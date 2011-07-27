Feature: Namespaced deploy tasks
  In order to avoid task name conflicts
  As a user
  I want to have namespaced deploy tasks

  Background:
    Given a directory named "deployer"
    And I cd to "deployer"
    And I stub out the "staging" deploy method
    And I stub out the "production" deploy method
    And I load the namespaced tasks

  Scenario: kumade:deploy task is an alias for kumade:deploy:staging
    When I successfully run the rake task "kumade:deploy"
    Then the output should contain "Force pushed master -> staging"

  Scenario: Deploying to staging
    When I successfully run the rake task "kumade:deploy:staging"
    Then the output should contain "Force pushed master -> staging"

  Scenario: Deploying to production
    When I successfully run the rake task "kumade:deploy:production"
    Then the output should contain "Force pushed master -> production"
