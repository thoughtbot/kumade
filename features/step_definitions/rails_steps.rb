Given /^a new Rails application with Kumade$/ do
  run_simple("rails new rake-tasks")
  cd('rake-tasks')
  append_to_file('Gemfile', "gem 'kumade', :path => '#{PROJECT_PATH}'")
  run_bundler
end
