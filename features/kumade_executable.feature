@extra-timeout @creates-remote
Feature: Kumade executable
  As a user
  I want to be able to use the kumade executable
  So I can have a better experience than Rake provides

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    When I successfully run `git init`
    And I successfully run `touch .gitkeep`
    And I successfully run `git add .`
    And I successfully run `git commit -am First`
    And I create a Heroku remote for "pretend-staging-app" named "pretend-staging"
    And I create a Heroku remote for "app-two" named "staging"
    And I create a non-Heroku remote named "bad-remote"

  Scenario: Pretend mode with a Heroku remote
    When I run `kumade deploy pretend-staging -p`
    Then the output should contain "In Pretend Mode"
    And the output should contain:
      """
      ==> Git repo is clean
      ==> Packaged assets with Jammit
               run  git push origin master
      ==> Pushed master -> origin
               run  git push -f pretend-staging deploy:master
      ==> Force pushed master -> pretend-staging
               run  bundle exec heroku rake db:migrate --app pretend-staging-app
      ==> Migrated pretend-staging-app
               run  git checkout master && git branch -D deploy
      ==> Deployed to: pretend-staging
      """
    But the output should not contain "==> Packaged assets with More"

  Scenario: Default environment is staging
    When I run `kumade -p`
    Then the output should contain "==> Deployed to: staging"

  Scenario: Can deploy to arbitrary environment
    When I run `kumade deploy bamboo`
    Then the output should contain "==> Deploying to: bamboo"
    Then the output should match /Cannot deploy: /

  Scenario: Deploying to a non-Heroku remote fails
    When I run `kumade deploy bad-remote`
    Then the output should match /==> ! Cannot deploy: "bad-remote" remote does not point to Heroku/
