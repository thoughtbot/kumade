When /^I create a Heroku remote for "([^"]*)" named "([^"]*)"$/ do |app_name, remote_name|
  run_simple(unescape("git remote add #{remote_name} git@heroku.com:#{app_name}.git"))
end

When /^I create a non-Heroku remote named "([^"]*)"$/ do |remote_name|
  run_simple(unescape("git remote add #{remote_name} git@github.com:gabebw/kumade.git"))
end

When /^I set up a git repo$/ do
  ["git init", "touch .gitkeep", "git add .", "git commit -am First"].each do |git_command|
    run_simple(unescape(git_command))
  end
end

When /^I commit everything in the current repo$/ do
  ['git add .', 'git commit -am MY_MESSAGE'].each do |git_command|
    run_simple(unescape(git_command))
  end
end

Before("@creates-remote") do
  in_current_dir do
    remove_all_git_remotes
  end
end

After("@creates-remote") do
  in_current_dir do
    remove_all_git_remotes
  end
end
