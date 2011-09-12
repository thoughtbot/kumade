module Kumade
  class Configuration
    def initialize(environment = 'staging', pretending = false, tests = true )
      @environment = environment
      @pretending  = pretending
      @tests = tests
    end

    def pretending?
      !!@pretending
    end
    
    def tests?
      @tests
    end

    attr_accessor :pretending, :environment, :tests
  end
end
