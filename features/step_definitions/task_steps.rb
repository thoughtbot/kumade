Given /^I load the non\-namespaced tasks$/ do
  prepend_require_kumade_to_rakefile!

  steps %{
    When I append to "Rakefile" with:
    """

    Kumade.load_tasks
    """
  }
end

Given /^I load the namespaced tasks$/ do
  prepend_require_kumade_to_rakefile!

  steps %{
    When I append to "Rakefile" with:
    """

    Kumade.load_namespaced_tasks
    """
  }
end

When /^I successfully run the rake task "([^"]*)"$/ do |task_name|
  When %{I successfully run `bundle exec rake #{task_name}`}
end
