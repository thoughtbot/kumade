require 'kumade/deployer'

class Kumade
  def self.load_tasks
    deployer.load_tasks
  end

  class << self
    attr_writer :staging, :production
    attr_accessor :staging_app, :production_app

    def reset!
      @staging    = nil
      @production = nil

      @staging_app    = nil
      @production_app = nil
    end

    def staging
      @staging ||= 'staging'
    end

    def production
      @production ||= 'production'
    end
  end

  def self.deployer
    @deployer ||= Deployer.new
  end
end
