@slow
Feature: Rake task that always runs during pre deploy
  As a user
  I want a Rake task that runs before deployment
  So that I can hook into the deployment process

  Scenario: Pre-deploy task runs during deployment
    Given a new Rails application with Kumade and Jammit
    When I create a Heroku remote named "pretend-staging"
    And I add a pre-deploy rake task that prints "Hi!"
    And I run kumade with "pretend-staging"
    Then the output should contain "kumade:pre_deploy"
    And the output should contain "Hi!"

  Scenario: Pre-deploy task does not run when pretending
    Given a new Rails application with Kumade and Jammit
    When I create a Heroku remote named "pretend-staging"
    And I add a pre-deploy rake task that prints "Hi!"
    And I run kumade with "pretend-staging -p"
    Then the output should contain "kumade:pre_deploy"
    But the output should not contain "Hi!"
