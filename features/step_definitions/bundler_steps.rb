When /^I bundle$/ do
  run_bundler
end

When /^I set up the Gemfile with kumade$/ do
  add_kumade_to_gemfile
end

When /^I add "jammit" to the Gemfile$/ do
  add_jammit_to_gemfile
end
