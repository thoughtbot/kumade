When /^I require the kumade railtie in the Rakefile$/ do
  rakefile_content = prep_for_fs_check { IO.readlines("Rakefile") }
  new_rakefile_content = rakefile_content.map do |line|
    if line.include?('load_tasks')
      ["require 'kumade/railtie'", line].join("\n")
    else
      line
    end
  end.join

  overwrite_file("Rakefile", new_rakefile_content)
end

Then /^the rake tasks should include "([^"]+)" with a description of "([^"]+)"$/ do |task_name, task_description|
  steps %{
    When I run `bundle exec rake -T`
    Then the output should match /#{task_name}.+#{task_description}/
  }
end

Then /^the rake tasks should not include "([^"]+)"/ do |task_name|
  steps %{
    When I run `bundle exec rake -T`
    Then the output from "bundle exec rake -T" should not contain "#{task_name}"
  }
end

When /^I add a pre-compilation rake task that prints "Hi!"$/ do
  append_to_file("Rakefile", <<-CUSTOM_TASK)
      namespace :kumade do
        task :before_asset_compilation do
          puts 'Hi!'
        end
      end
  CUSTOM_TASK

  commit_everything_in_repo
end

When /^I add a pre-deploy rake task that prints "Hi!"$/ do
  append_to_file("Rakefile", <<-CUSTOM_TASK)
      namespace :kumade do
        task :pre_deploy do
          puts 'Hi!'
        end
      end
  CUSTOM_TASK

  commit_everything_in_repo
end
