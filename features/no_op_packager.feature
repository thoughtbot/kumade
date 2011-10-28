@slow
Feature: No-op packager
  As a user
  I want Kumade to gracefully handle occasions when I have no assets to package
  So that I am not forced to package my assets

  Background:
    Given a new Rails application with Kumade
    When I create a Heroku remote named "staging"

  Scenario: No-op packager does not run in pretend mode if Jammit is not installed
    When I run kumade with "staging -p"
    Then the output should not contain "==> Packaged with Kumade::NoopPackager"

  Scenario: No-op packager does not run in normal mode if Jammit is not installed
    When I add the origin remote
    And I run kumade
    Then the output should not contain "==> Packaged with Kumade::NoopPackager"
