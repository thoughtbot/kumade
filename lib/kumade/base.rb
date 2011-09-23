require "thor"

module Kumade
  class Base < Thor::Shell::Color
    def initialize
      super()
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
