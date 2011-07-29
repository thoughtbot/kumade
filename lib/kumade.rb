require 'kumade/deployer'
require 'kumade/thor_task'

class Kumade
  def self.load_tasks
    deployer.load_tasks
  end

  def self.load_namespaced_tasks
    deployer.load_namespaced_tasks
  end

  def self.deployer
    @deployer ||= Deployer.new
  end

  class << self
    attr_writer :staging_remote, :production_remote
    attr_accessor :staging_app, :production_app

    def reset!
      @staging_remote    = nil
      @production_remote = nil

      @staging_app    = nil
      @production_app = nil
    end

    def staging_remote
      @staging_remote ||= local_remote_for_app(Kumade.staging_app)
    end

    def production_remote
      @production_remote ||= local_remote_for_app(Kumade.production_app)
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
