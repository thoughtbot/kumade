require "rake"
require 'cocaine'

module Kumade
  class Deployer
    attr_reader :git, :heroku, :packager

    def initialize
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
        heroku.restart_app
        post_deploy_success
      rescue => deploying_error
        Kumade.configuration.outputter.error("#{deploying_error.class}: #{deploying_error.message}")
      ensure
        post_deploy
      end
    end

    def pre_deploy
      ensure_clean_git
      run_pre_deploy_task
      package_assets
      sync_origin
    end

    def post_deploy_success
      run_post_deploy_task
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

    def ensure_heroku_remote_exists
      if git.remote_exists?(Kumade.configuration.environment)
        if git.heroku_remote?
          Kumade.configuration.outputter.success("#{Kumade.configuration.environment} is a Heroku remote")
        else
          Kumade.configuration.outputter.error(%{Cannot deploy: "#{Kumade.configuration.environment}" remote does not point to Heroku})
        end
      else
        Kumade.configuration.outputter.error(%{Cannot deploy: "#{Kumade.configuration.environment}" remote does not exist})
      end
    end

    private

    def run_pre_deploy_task
      RakeTaskRunner.new("kumade:pre_deploy").invoke
    end

    def run_post_deploy_task
      RakeTaskRunner.new("kumade:post_deploy").invoke
    end
  end
end
