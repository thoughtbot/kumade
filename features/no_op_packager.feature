@slow @creates-remote @disable-bundler
Feature: No-op packager
  As a user
  I want Kumade to gracefully handle occasions when I have no assets to package
  So that I am not forced to package my assets

  Background:
    Given a new Rails app
    When I create a Heroku remote for "my-app" named "staging"

  Scenario: No-op packager runs in pretend mode if Jammit is not installed
    When I run kumade with "staging -p"
    Then the output should contain "==> Packaged with Kumade::NoopPackager"

  Scenario: No-op packager runs in normal mode if Jammit is not installed
    When I run kumade with "staging -v"
    Then the output should contain "==> Packaged with Kumade::NoopPackager"
