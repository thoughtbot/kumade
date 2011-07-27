require 'kumade/deployer'

class Kumade
  def self.load_tasks
    deployer.load_tasks
  end

  def self.deployer
    @deployer ||= Deployer.new
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
      @staging ||= local_remote_for_app(Kumade.staging_app)
    end

    def production
      @production ||= local_remote_for_app(Kumade.production_app)
    end

    def local_remote_for_app(app_name)
      heroku_remote_url = heroku_remote_url_for_app(app_name)
      `git remote -v | grep push | grep '#{heroku_remote_url}' | cut -f1`.strip
    end

    def heroku_remote_url_for_app(app_name)
      "git@heroku.com:#{app_name}.git"
    end
  end
end
