require "rake"
require 'cocaine'

module Kumade
  class Deployer < Base
    attr_reader :git, :packager
    DEPLOY_BRANCH = "deploy"
    def initialize
      super()
      @git    = Git.new
      @branch = @git.current_branch
      @packager    = Packager.new(@git)
    end

    def deploy
      begin
        ensure_heroku_remote_exists
        pre_deploy
        sync_heroku
        heroku_migrate
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
      packager.run 
    end

    def sync_github
      git.push(@branch)
    end

    def sync_heroku
      git.create(DEPLOY_BRANCH)
      git.push("#{DEPLOY_BRANCH}:master", Kumade.configuration.environment, true)
    end

    def heroku_migrate
      heroku("rake db:migrate") unless Kumade.configuration.pretending?
      success("Migrated #{Kumade.configuration.environment}")
    end

    def post_deploy
      git.delete(DEPLOY_BRANCH, @branch)
    end

    def heroku(command)
      heroku_command = if cedar?
                         "bundle exec heroku run"
                       else
                         "bundle exec heroku"
                       end
      run_or_error("#{heroku_command} #{command} --remote #{Kumade.configuration.environment}",
                   "Failed to run #{command} on Heroku")
    end

    def cedar?
      return @cedar unless @cedar.nil?
      @cedar = Cocaine::CommandLine.new("bundle exec heroku stack --remote #{Kumade.configuration.environment}").run.split("\n").grep(/\*/).any? do |line|
        line.include?("cedar")
      end
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
