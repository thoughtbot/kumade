@slow
Feature: Kumade without jammit

  Background:
    Given a directory set up for kumade
    When I create a Heroku remote named "pretend-staging"

  Scenario: Jammit packager does not run if Jammit is not installed
    When I run kumade with "pretend-staging"
    Then the output should not contain "==> ! Error: Jammit::MissingConfiguration"
