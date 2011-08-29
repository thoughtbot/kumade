module Kumade
  class Git < Thor::Shell::Color
    def initialize(pretending, environment)
      super()
      @pretending = pretending
      @environment = environment
    end
    
    def push(branch, remote = 'origin', force = false)
      command = ["git push"]
      command << "-f" if force
      command << remote
      command << branch
      command = command.join(" ")
      run_or_error([command], "Failed to push #{branch} -> #{remote}")
      success("Pushed #{branch} -> #{remote}")
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
      exit 1
    end
    
    def success(message)
      say("==> #{message}", :green)
    end
  end
end