Given /^a new Rails application with Kumade$/ do
  create_rails_app_with_kumade
end

Given /^a new Rails application with Kumade and Jammit$/ do
  create_rails_app_with_kumade_and_jammit
end

When /^I configure my Rails app for Jammit$/ do
  run_bundler
  set_up_jammit
  add_origin_remote
end
