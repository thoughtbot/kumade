When /^I bundle$/ do
  run_bundler
end

When /^I rebundle$/ do
  run_bundler
  commit_everything_in_repo
end

Given /^an empty Gemfile$/ do
  write_file('Gemfile', '')
end

When /^I set up the Gemfile with kumade$/ do
  add_kumade_to_gemfile
end

When /^I add "jammit" to the Gemfile$/ do
  add_jammit_to_gemfile
end
