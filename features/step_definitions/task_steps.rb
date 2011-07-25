When /^I load the tasks$/ do
  prepend_require_kumade_to_rakefile!

  steps %{
    When I append to "Rakefile" with:
    """

    Kumade.load_tasks
    """
  }
end

When /^I add a failing default task$/ do
  steps %{
    When I append to "Rakefile" with:
    """

    task :failing_task do
      raise "I am the failboat!"
    end
    task :default => :failing_task
    """
  }
end

Given /^I stub out the "([^"]+)" task$/ do |task_name|
  insert_after_tasks_are_loaded(<<-CONTENT)
    class Rake::Task
      def overwrite(&block)
        @actions.clear
        enhance(&block)
      end
    end

    Rake::Task['#{task_name}'].overwrite do
      puts "[stub] Ran #{task_name}"
    end
  CONTENT
end
