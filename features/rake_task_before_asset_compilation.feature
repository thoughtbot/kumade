@slow
Feature: Rake task that runs before asset compilation
  As a user
  I want a Rake task that runs before packaging
  So that I can hook into the packaging process

  Scenario: Custom task runs if Jammit is installed
    Given a new Rails application with Kumade and Jammit
    When I create a Heroku remote named "pretend-staging"
    And I add a pre-compilation rake task that prints "Hi!"
    And I run kumade with "pretend-staging"
    Then the output should contain "kumade:before_asset_compilation"
    And the output should contain "Hi!"

  Scenario: Custom task runs if Jammit is not installed
    Given a new Rails application with Kumade
    When I create a Heroku remote named "pretend-staging"
    And I add a pre-compilation rake task that prints "Hi!"
    And I run kumade with "pretend-staging"
    Then the output should contain "kumade:before_asset_compilation"
    And the output should contain "Hi!"

  Scenario: Pre-asset compilation task does not run when pretending
    Given a new Rails application with Kumade and Jammit
    When I create a Heroku remote named "pretend-staging"
    And I add a pre-compilation rake task that prints "Hi!"
    And I run kumade with "pretend-staging -p"
    Then the output should contain "kumade:before_asset_compilation"
    But the output should not contain "Hi!"
