Feature: Deploying to Heroku
  In order to easily use Heroku's services
  As a user
  I want to deploy to Heroku

  Background:
    Given a directory named "deployer"
    And I cd to "deployer"
    And I stub out the "staging" deploy method
    And I stub out the "production" deploy method
    And I load the non-namespaced tasks

  Scenario: deploy task is an alias for kumade:deploy
    When I successfully run the rake task "deploy"
    Then the output should contain "Force pushed master -> staging"

  Scenario: Deploying to staging with deploy:staging
    When I successfully run the rake task "deploy:staging"
    Then the output should contain "Force pushed master -> staging"

  Scenario: Deploying to production with deploy:production
    When I successfully run the rake task "deploy:production"
    Then the output should contain "Force pushed master -> production"
