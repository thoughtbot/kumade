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

  Scenario: Can deploy to staging
    When I run `kumade deploy staging -p`
    Then the output should contain "==> Deploying to: staging"
    And the output should contain "==> Deployed to: staging"

  Scenario: Can deploy to production
    When I run `kumade deploy production -p`
    Then the output should contain "==> Deploying to: production"
    And the output should contain "==> Deployed to: production"

  Scenario: Cannot deploy to arbitrary environment
    When I run `kumade deploy bamboo -p`
    Then the output should contain "==> Deploying to: bamboo"
    And the output should contain "==> Cannot deploy: env must be either staging or production"
