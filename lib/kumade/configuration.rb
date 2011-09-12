module Kumade
  class Configuration
    def initialize(environment = 'staging', pretending = false )
      @environment = environment
      @pretending  = pretending
    end

    def pretending?
      !!@pretending
    end

    attr_accessor :pretending, :environment
  end
end
