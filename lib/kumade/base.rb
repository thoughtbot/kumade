require "thor"

module Kumade
  class Base < Thor::Shell::Color
    def initialize
      super()
    end

    def run_or_error(command, error_message)
      say_status(:run, command)
      if ! Kumade.configuration.pretending?
        error(error_message) unless run(command)
      end
    end

    def run(command)
      line = Cocaine::CommandLine.new(command)
      begin
        line.run
        true
      rescue Cocaine::ExitStatusError => e
        false
      end
    end

    def error(message)
      say("==> ! #{message}", :red)
      raise Kumade::DeploymentError.new(message)
    end

    def success(message)
      say("==> #{message}", :green)
    end
    
    def invoke_task(task)
      if task_exist?(task)
        success "Running #{task} task"
        Rake::Task[task].invoke unless Kumade.configuration.pretending?
      end
    end
    
    def task_exist?(task)
      load("Rakefile") if File.exist?("Rakefile")
      Rake::Task.task_defined?(task)
    end
  end
end
