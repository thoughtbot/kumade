When /^I load the tasks$/ do
  prepend_require_kumade_to_rakefile!

  steps %{
    When I append to "Rakefile" with:
    """

    Kumade.load_tasks
    """
  }
end
