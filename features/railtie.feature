Feature: Railtie
  As a Rake user
  I want Kumade to autoload Rake tasks for my Rails application
  So that I can integrate Kumade with other Rake tasks

  @creates-remote @disable-bundler @slow
  Scenario: Rake tasks are loaded
    Given a new Rails application with Kumade
    When I require the kumade railtie in the Rakefile
    And I create a Heroku remote named "staging"
    And I create a non-Heroku remote named "bad-remote"
    And I run `bundle exec rake -T`
    Then the output should match /deploy:staging.+Deploy to staging environment/
    But the output from "bundle exec rake -T" should not contain "deploy:bad-remote"
