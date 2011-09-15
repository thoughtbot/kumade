module Kumade
  class Configuration
    attr_writer :pretending, :environment

    def pretending?
      @pretending || false
    end

    def environment
      @environment || "staging"
    end
  end
end
