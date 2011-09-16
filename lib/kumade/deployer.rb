require "rake"
require 'cocaine'

module Kumade
  class Deployer < Base
    attr_reader :git, :heroku, :packager

    def initialize
      super()
      @git      = Git.new
      @heroku   = Heroku.new
      @branch   = @git.current_branch
      @packager = Packager.new(@git)
    end

    def deploy
      begin
        ensure_heroku_remote_exists
        pre_deploy
        heroku.sync
        heroku.migrate_database
      rescue
      ensure
        post_deploy
      end
    end

    def pre_deploy
      ensure_clean_git
      package_assets
      sync_github
    end

    def package_assets
      @packager.run
    end

    def sync_github
      git.push(@branch)
    end

    def post_deploy
      heroku.delete_deploy_branch
    end

    def ensure_clean_git
      git.ensure_clean_git
    end

    def ensure_heroku_remote_exists
      if git.remote_exists?(Kumade.configuration.environment)
        if git.heroku_remote?
          success("#{Kumade.configuration.environment} is a Heroku remote")
        else
          error(%{Cannot deploy: "#{Kumade.configuration.environment}" remote does not point to Heroku})
        end
      else
        error(%{Cannot deploy: "#{Kumade.configuration.environment}" remote does not exist})
      end
    end
  end
end
