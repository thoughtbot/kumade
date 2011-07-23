Feature: Deploying to Heroku
  In order to easily use Heroku's services
  As a user
  I want to deploy to Heroku

  Background:
    Given a directory named "deployer"
    When I cd to "deployer"
     And I write to "Gemfile" with:
    """
    source "http://rubygems.org"
    gem "rake", "0.8.7"
    gem "kumade"
    """
    And I add "kumade" from this project as a dependency
    And I load the tasks with a stub for git push

  Scenario: deploy task is an alias for deploy:staging
    When I run `rake deploy`
    Then the output should contain "[stub] Deployed to staging"

  Scenario: Deploying to staging
    When I run `rake deploy:staging`
    Then the output should contain "[stub] Deployed to staging"

  Scenario: Deploying to production
    When I run `rake deploy:production`
    Then the output should contain "[stub] Deployed to production"
