@creates-remote @disable-bundler
Feature: Jammit
  As a user
  I want Kumade to auto-package with Jammit
  So that I don't have to remember to package assets

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    And I set up the Gemfile with kumade
    And I add "jammit" to the Gemfile
    And I bundle
    When I set up a git repo
    And I create a Heroku remote named "pretend-staging"

  Scenario: Jammit packager runs if Jammit is installed
    When I run kumade with "pretend-staging"
    Then the output from "bundle exec kumade pretend-staging" should contain "==> ! Error: Jammit::MissingConfiguration"

  Scenario: Run custom task before jammit
    Given I write to "Rakefile" with:
      """
      namespace :kumade do
        task :before_asset_compilation do
          puts 'Hi!'
        end
      end
      """
    When I run kumade with "pretend-staging -p"
    Then the output should contain "kumade:before_asset_compilation"
    And the output should contain "==> Packaged with Kumade::JammitPackager"
