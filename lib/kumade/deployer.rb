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
        heroku.pre_deploy
        pre_deploy
        heroku.deploy
      rescue Kumade::DeploymentError
        raise
      rescue
      ensure
        post_deploy
      end
    end

    def pre_deploy
      ensure_clean_git
      package_assets
      sync_origin
    end

    def package_assets
      @packager.run
    end

    def sync_origin
      git.push(@branch)
    end

    def post_deploy
      heroku.delete_deploy_branch
    end

    def ensure_clean_git
      git.ensure_clean_git
    end
  end
end
