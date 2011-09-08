module Kumade
  class Base < Thor::Shell::Color
    DEPLOY_BRANCH = "deploy"
    def initialize
      super()
    end

    def run_or_error(commands, error_message)
      all_commands = [commands].flatten.join(' && ')
      if @pretending
        say_status(:run, all_commands)
      else
        error(error_message) unless run(all_commands)
      end
    end

    def run(command, config = {})
      say_status :run, command
      config[:capture] ? `#{command}` : system("#{command}")
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
