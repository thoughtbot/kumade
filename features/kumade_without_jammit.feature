@slow @creates-remote @disable-bundler
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

  Scenario: Run custom task if it exists
    Given I write to "Rakefile" with:
      """
      namespace :kumade do
        task :before_asset_compilation do
          puts 'Hi!'
        end
      end
      """
    When I run kumade with "pretend-staging"
    Then the output should contain "Running rake task: kumade:before_asset_compilation"
    And the output should contain "Hi!"

  Scenario: Don't run rake task in pretend mode
    Given I write to "Rakefile" with:
      """
      namespace :kumade do
        task :before_asset_compilation do
          puts 'Hi!'
        end
      end
      """
    When I run kumade with "pretend-staging -p"
    Then the output should contain "Running rake task: kumade:before_asset_compilation"
    And the output should not contain "Hi!"
