module Kumade
  class Outputter
    def success(message)
      puts "==> #{message}"
    end

    def info(message)
      puts "==> #{message}"
    end

    def error(message)
      puts "==> ! #{message}"
      raise Kumade::DeploymentError, message
    end
  end
end
