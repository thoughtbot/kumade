@slow @creates-remote @disable-bundler
Feature: Jammit
  As a user
  I want Kumade to auto-package with Jammit
  So that I don't have to remember to package assets

  Background:
    Given a new Rails application with Kumade and Jammit
    When I configure my Rails app for Jammit
    And I create a Heroku remote named "staging"

  Scenario: Jammit packager runs if Jammit is installed
    When I run kumade
    Then the output should contain "==> Packaged with Kumade::JammitPackager"

  Scenario: Run custom task before jammit
    When I add a pre-compilation rake task that prints "Hi!"
    And I run kumade
    Then the output should contain "kumade:before_asset_compilation"
    And the output should contain "Hi!"
