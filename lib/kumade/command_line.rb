require 'cocaine'

module Kumade
  class CommandLine < Base
    def initialize(command_to_run)
      super()
      @command_line = Cocaine::CommandLine.new(command_to_run)
    end

    def run_or_error(error_message = nil)
      run_with_status || error(error_message)
    end

    def run_with_status
      say_status(:run, command)
      Kumade.configuration.pretending? || run
    end

    def run
      begin
        @command_line.run
        true
      rescue Cocaine::ExitStatusError, Cocaine::CommandNotFoundError
        false
      end
    end

    private

    def command
      @command_line.command
    end
  end
end
