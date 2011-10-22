When /^I run kumade with "([^"]+)"$/ do |args|
  When %{I run `bundle exec kumade #{args}`}
end

Given /^I have loaded "([^"]+)"$/ do |file|
  in_current_dir do
    load(file)
  end
end

Given /^a directory set up for kumade$/ do
  steps %{
    Given a directory named "the-kumade-directory"
    When I cd to "the-kumade-directory"
    And I set up the Gemfile with kumade
    And I bundle
    And I set up a git repo
  }
end
