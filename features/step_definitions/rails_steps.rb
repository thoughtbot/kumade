Given /^a new Rails application with Kumade$/ do
  run_simple("rails new rake-tasks -T")
  cd('rake-tasks')
  append_to_file('Gemfile', "gem 'kumade', :path => '#{PROJECT_PATH}'")
  run_bundler
  set_up_git_repo
end

Given /^a new Rails application with Kumade and Jammit$/ do
  Given "a new Rails application with Kumade"
  add_jammit_to_gemfile
  run_bundler
  set_up_git_repo
end
