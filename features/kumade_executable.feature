Feature: Kumade executable
  As a user
  I want to be able to use the kumade executable
  So I can have a better experience than Rake provides

  Background:
    Given a directory named "executable"
    And I cd to "executable"

  Scenario: Pretend mode
    When I run `kumade -p`
    Then the output should contain "In Pretend Mode"

  Scenario: Default environment is staging
    When I run `kumade -p`
    Then the output should contain "==> Deploying to: staging"
    And the output should contain "==> Deployed to: staging"

  Scenario Outline: Can deploy to arbitrary environment
    When I run `kumade deploy <env>`
    Then the output should contain "==> Deploying to: <env>"
    Then the output should match /Cannot deploy: "<env>" remote does not exist/

    Examples:
      | env        |
      | staging    |
      | production |
      | bamboo     |
