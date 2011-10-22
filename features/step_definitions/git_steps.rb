After("@creates-remote") do
  remove_all_created_remotes
end

When /^I create a Heroku remote named "([^"]*)"$/ do |remote_name|
  add_heroku_remote_named(remote_name)
end

When /^I create a non-Heroku remote named "([^"]*)"$/ do |remote_name|
  add_non_heroku_remote_named(remote_name)
end

When /^I set up a git repo$/ do
  ["git init", "touch .gitkeep", "git add .", "git commit -am First"].each do |git_command|
    run_simple(git_command)
  end
end

When /^I commit everything in the current repo$/ do
  ['git add .', 'git commit -am MY_MESSAGE'].each do |git_command|
    run_simple(git_command)
  end
end

When /^I create an untracked file$/ do
  write_file("untracked-file", "anything")
end

When /^I modify a tracked file$/ do
  steps %{
    Given I write to "new-file" with:
      """
      clean
      """
    And I commit everything in the current repo
    When I append to "new-file" with "dirty it up"
  }
end
