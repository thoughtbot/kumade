@slow @disable-bundler
Feature: Kumade without jammit

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    And I set up the Gemfile with kumade
    And I bundle
    When I set up a git repo
    And I create a Heroku remote named "pretend-staging"

  Scenario: Jammit packager does not run if Jammit is not installed
    When I run kumade with "pretend-staging"
    Then the output should not contain "==> ! Error: Jammit::MissingConfiguration"
