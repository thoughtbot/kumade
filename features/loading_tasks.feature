Feature: Loading tasks
  In order to use Kumade
  As a user
  I want to load Rake tasks

  Scenario: Load Rake tasks
    Given a directory named "taskloader"
    When I cd to "taskloader"
     And I write to "Gemfile" with:
    """
    source "http://rubygems.org"
    gem "rake", "0.8.7"
    gem "kumade"
    """
    And I write to "Rakefile" with:
    """
    require 'kumade'
    Kumade.load_tasks
    """
    And I run `rake -T`
    Then the output should contain "deploy"
    And the output should contain "deploy:staging"
    And the output should contain "deploy:production"
