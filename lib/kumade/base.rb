require "thor"

module Kumade
  class Base < Thor::Shell::Color
    DEPLOY_BRANCH = "deploy"
    attr_reader :pretending

    def initialize
      super()
    end

    def run_or_error(command, error_message)
      say_status(:run, command)
      if !pretending
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
  end
end
