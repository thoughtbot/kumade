module Kumade
  class Configuration
    def initialize
      @environment = 'staging'
      @pretending  = false
    end

    def pretending?
      !!@pretending
    end

    attr_accessor :pretending, :environment
  end
end
