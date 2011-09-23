require 'cocaine'

module Kumade
  class CommandFailedError < RuntimeError
  end

  class CommandLine < Base
    def initialize(command_to_run)
      super()
      @command_line = Cocaine::CommandLine.new(command_to_run)
    end

    def run_or_error(error_message = nil)
      if run_with_status
        true
      else
        error(error_message)
      end
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
