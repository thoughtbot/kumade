module Kumade
  class RakeTaskRunner
    def initialize(task_name, runner)
      @task_name = task_name
      @runner    = runner
    end

    def invoke
      return unless task_defined?

      @runner.success("Running rake task: #{@task_name}")
      Rake::Task[@task_name].invoke if task_should_be_run?
    end

    private

    def task_defined?
      load_rakefile
      Rake::Task.task_defined?(@task_name)
    end

    def task_should_be_run?
      !Kumade.configuration.pretending?
    end

    def load_rakefile
      load("Rakefile") if File.exist?("Rakefile")
    end
  end
end
