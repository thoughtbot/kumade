When /^I create a Heroku remote for "([^"]*)" named "([^"]*)"$/ do |app_name, remote_name|
  When %{I run `git remote add #{remote_name} git@heroku.com:#{app_name}.git`}
end

When /^I create a non-Heroku remote named "([^"]*)"$/ do |remote_name|
  When %{I run `git remote add #{remote_name} git@github.com:gabebw/kumade.git`}
end

After("@creates-remote") do
  heroku_remotes = `git remote -v show | grep heroku | grep fetch | cut -f1`.strip.split
  heroku_remotes.each { |remote| `git remote rm #{remote} 2> /dev/null` }
end
