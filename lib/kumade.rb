require 'kumade/deployer'

class Kumade
  def self.load_tasks
    deployer.load_tasks
  end

  class << self
    attr_writer :staging, :production

    def reset_remotes!
      @staging = nil
      @production = nil
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
