When /^I create a Heroku remote for "([^"]*)" named "([^"]*)"$/ do |app_name, remote_name|
  When %{I successfully run `git remote add #{remote_name} git@heroku.com:#{app_name}.git`}
end

When /^I create a non-Heroku remote named "([^"]*)"$/ do |remote_name|
  When %{I successfully run `git remote add #{remote_name} git@github.com:gabebw/kumade.git`}
end

When /^I set up a git repo$/ do
  steps %{
    When I successfully run `git init`
    And I successfully run `touch .gitkeep`
    And I successfully run `git add .`
    And I successfully run `git commit -am First`
  }
end

When /^I commit everything in the current repo$/ do
  steps %{
    When I successfully run `git add .`
    And I successfully run `git commit -am MY_MESSAGE`
  }
end

After("@creates-remote") do
  heroku_remotes = `git remote -v show | grep heroku | grep fetch | cut -f1`.strip.split
  heroku_remotes.each { |remote| `git remote rm #{remote} 2> /dev/null` }
end
