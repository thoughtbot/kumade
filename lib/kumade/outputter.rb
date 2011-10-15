module Kumade
  class Outputter
    def success(message)
      STDOUT.puts "==> #{message}"
    end

    def info(message)
      STDOUT.puts "==> #{message}"
    end

    def error(message)
      STDOUT.puts "==> ! #{message}"
      raise Kumade::DeploymentError, message
    end

    def say_command(command)
      prefix = " " * 8
      STDOUT.puts "#{prefix}#{command}"
    end
  end
end
