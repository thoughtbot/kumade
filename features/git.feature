@disable-bundler
Feature: Git cleanliness
  As a user
  I want Kumade to check if git is clean before deploying
  So that I don't accidentally leave leave local changes behind

  Background:
    Given a directory set up for kumade
    When I create a Heroku remote named "pretend-staging"

  Scenario: Git is clean if there are untracked files
    When I create an untracked file
    And I run kumade with "pretend-staging"
    Then the output should not contain "==> ! Cannot deploy: repo is not clean"

  Scenario: Git is not clean if a tracked file is modified
    When I modify a tracked file
    And I run kumade with "pretend-staging"
    Then the output should contain "==> ! Cannot deploy: repo is not clean"

  Scenario: Git repo is always clean when pretending
    Given a dirty repo
    When I run kumade with "pretend-staging -p"
    Then the output should contain "==> Git repo is clean"
