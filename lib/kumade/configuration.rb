module Kumade
  class Configuration
    attr_writer :pretending, :environment

    def pretending?
      @pretending || false
    end

    def environment
      @environment || "staging"
    end

    def outputter
      @outputter ||= Outputter.new
    end

    def outputter=(new_outputter)
      @outputter = new_outputter
    end
  end
end
