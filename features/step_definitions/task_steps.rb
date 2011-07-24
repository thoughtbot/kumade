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

When /^I stub out the pre\-deploy task$/ do
  insert_after_tasks_are_loaded(<<-CONTENT)
    class Rake::Task
      def overwrite(&block)
        @actions.clear
        enhance(&block)
      end
    end

    Rake::Task['deploy:pre_deploy'].overwrite do
      puts "[stub] Successfully ran pre-deploy hook"
    end
  CONTENT
end
