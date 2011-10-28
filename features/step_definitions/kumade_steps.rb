When /^I run kumade$/ do
  run_simple("bundle exec kumade", must_be_successful = false)
end

When /^I run kumade with "([^"]+)"$/ do |args|
  run_simple("bundle exec kumade #{args}", must_be_successful = false)
end

Given /^a directory set up for kumade$/ do
  create_dir('the-kumade-directory')
  cd('the-kumade-directory')
  add_kumade_to_gemfile
  run_bundler
  set_up_git_repo
end
