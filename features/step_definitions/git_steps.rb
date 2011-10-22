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
  set_up_git_repo
end

When /^I commit everything in the current repo$/ do
  commit_everything_in_repo
end

When /^I create an untracked file$/ do
  write_file("untracked-file", "anything")
end

When /^I modify a tracked file$/ do
  write_file('tracked-file', 'clean')
  commit_everything_in_repo
  append_to_file('tracked-file', 'dirty it up')
end
