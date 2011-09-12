require 'cocaine'

module Kumade
  class Heroku < Base
    DEPLOY_BRANCH = "deploy"
    attr_reader :git

    def initialize
      super()
      @git    = Git.new
      @branch = @git.current_branch
    end

    def sync
      git.create(DEPLOY_BRANCH)
      git.push("#{DEPLOY_BRANCH}:master", Kumade.configuration.environment, true)
    end

    def migrate_database
      heroku("rake db:migrate") unless Kumade.configuration.pretending?
      success("Migrated #{Kumade.configuration.environment}")
    end

    def delete_deploy_branch
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
  end
end
