require 'cocaine'

module Kumade
  class CommandLine
    attr_reader :last_command_output

    def initialize(command_to_run)
      @command_line = Cocaine::CommandLine.new(command_to_run)
    end

    def run_or_error(error_message = nil)
      run_with_status || Kumade.configuration.outputter.error(error_message)
    end

    def run_with_status
      Kumade.configuration.outputter.say_command(command)
      Kumade.configuration.pretending? || run
    end

    def run
      begin
        @last_command_output = @command_line.run
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
