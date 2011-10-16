require 'cocaine'

module Kumade
  class Heroku
    DEPLOY_BRANCH = "deploy"
    attr_reader :git

    def initialize
      @git    = Git.new
      @branch = @git.current_branch
    end

    def pre_deploy
      ensure_heroku_remote_exists
    end

    def deploy
      begin
        sync
        migrate_database
      rescue => deploying_error
        Kumade.configuration.outputter.error("#{deploying_error.class}: #{deploying_error.message}")
      ensure
        post_deploy
      end
    end

    def post_deploy
      delete_deploy_branch
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

    def sync
      git.create(DEPLOY_BRANCH)
      git.push("#{DEPLOY_BRANCH}:master", Kumade.configuration.environment, true)
    end

    def migrate_database
      heroku("rake db:migrate") unless Kumade.configuration.pretending?
      Kumade.configuration.outputter.success("Migrated #{Kumade.configuration.environment}")
    end

    def delete_deploy_branch
      git.delete(DEPLOY_BRANCH, @branch)
    end

    def heroku(command)
      full_heroku_command = "#{bundle_exec_heroku} #{command} --remote #{Kumade.configuration.environment}"
      command_line = CommandLine.new(full_heroku_command)
      command_line.run_or_error("Failed to run #{command} on Heroku")
    end

    def cedar?
      return @cedar unless @cedar.nil?

      command_line = CommandLine.new("bundle exec heroku stack --remote #{Kumade.configuration.environment}")

      @cedar = command_line.run_or_error.split("\n").grep(/\*/).any? do |line|
        line.include?("cedar")
      end
    end

    private

    def bundle_exec_heroku
      if cedar?
        "bundle exec heroku run"
      else
        "bundle exec heroku"
      end
    end
  end
end
