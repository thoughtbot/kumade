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
    And I stub out git push
    And I stub out git force push
    And I load the tasks
    And I initialize a git repo
    And I commit everything in the current directory to git

  Scenario: deploy task is an alias for deploy:staging
    When I successfully run `rake deploy`
    Then the output should contain "Force pushed master -> staging"

  Scenario: Deploying to staging calls pre-deploy hook
    When I stub out the pre-deploy task
    And I successfully run `rake deploy:staging`
    Then the output should contain "[stub] Successfully ran pre-deploy hook"

  Scenario: Deploying to production calls pre-deploy hook
    When I stub out the pre-deploy task
    And I successfully run `rake deploy:production`
    Then the output should contain "[stub] Successfully ran pre-deploy hook"

  Scenario: Deploying to staging
    When I successfully run `rake deploy:staging`
    Then the output should contain "Force pushed master -> staging"
    And the output should contain "Pushed master -> origin"

  Scenario: Deploying to production
    When I successfully run `rake deploy:production`
    Then the output should contain "Force pushed master -> production"
    And the output should contain "Pushed master -> origin"

  Scenario: Pushing to origin fails
    Given that pushing to origin fails
    When I run `rake deploy:pre_deploy`
    Then the output should contain "Failed to push master -> origin"

  Scenario: Pre-deploy hook checks for clean git repo
    When I append to "Rakefile" with:
    """
    # Dirtying up your git repo
    """
    And I run `rake deploy:pre_deploy`
    Then the output should contain "Cannot deploy: repo is not clean"

  Scenario: Pre-deploy hook checks that rake passes
    When I add a failing default task
    And I commit everything in the current directory to git
    And I run `rake deploy:pre_deploy`
    Then the output should contain "Cannot deploy: tests did not pass"
