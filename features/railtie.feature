Feature: Railtie
  As a Rake user
  I want Kumade to autoload Rake tasks for my Rails application
  So that I can integrate Kumade with other Rake tasks

  @creates-remote @disable-bundler @slow
  Scenario: Rake tasks are loaded
    Given a new Rails application with Kumade
    When I create a Heroku remote named "staging"
    And I create a non-Heroku remote named "bad_remote"
    Then the rake tasks should include "deploy:staging" with a description of "Deploy to staging environment"
    But the rake tasks should not include "deploy:bad_remote"
