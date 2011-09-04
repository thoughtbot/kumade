module Kumade
  class Deployer < Base
    attr_reader :git, :packager
    def initialize(environment = 'staging', pretending = false, cedar = false)
      super()
      @environment = environment
      @pretending  = pretending
      @cedar       = cedar
      @git         = Git.new(pretending, environment)
      @branch      = @git.current_branch
      @packager    = Packager.new(pretending, environment, @git)
    end

    def deploy
      ensure_heroku_remote_exists
      pre_deploy
      sync_heroku
      heroku_migrate
      post_deploy
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
      git.push("#{DEPLOY_BRANCH}:master", environment, true)
    end

    def heroku_migrate
      heroku("rake db:migrate") unless pretending
      success("Migrated #{environment}")
    end

    def post_deploy
      git.delete(DEPLOY_BRANCH, @branch)
    end

    def heroku(command)
      heroku_command = if @cedar
                         "bundle exec heroku run"
                       else
                         "bundle exec heroku"
                       end
      run_or_error("#{heroku_command} #{command} --remote #{environment}",
                   "Failed to run #{command} on Heroku")
    end

    def ensure_clean_git
      git.ensure_clean_git
    end

    def ensure_heroku_remote_exists
      if git.remote_exists?(environment)
        if git.heroku_remote?
          success("#{environment} is a Heroku remote")
        else
          error(%{Cannot deploy: "#{environment}" remote does not point to Heroku})
        end
      else
        error(%{Cannot deploy: "#{environment}" remote does not exist})
      end
    end
  end
end
