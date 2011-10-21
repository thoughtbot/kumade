When /^I bundle$/ do
  run_bundler
end

When /^I rebundle$/ do
  steps %{
    When I bundle
    And I commit everything in the current repo
  }
end

Given /^an empty Gemfile$/ do
  When %{I write to "Gemfile" with:}, ""
end

When /^I set up the Gemfile with kumade$/ do
  steps %{
    When I write to "Gemfile" with:
      """
      gem 'kumade', :path => '../../..'
      """
  }
end

When /^I add "([^"]+)" to the Gemfile$/ do |gem|
  steps %{
    When I append to "Gemfile" with:
      """

      gem '#{gem}'
      """
  }
end
