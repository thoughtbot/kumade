require 'cocaine'

module Kumade
  class Heroku
    DEPLOY_BRANCH = "deploy"
    attr_reader :git

    def initialize
      @git    = Git.new
      @branch = @git.current_branch
    end

    def sync
      git.create(DEPLOY_BRANCH)
      git.push("#{DEPLOY_BRANCH}:master", Kumade.configuration.environment, true)
    end

    def migrate_database
      heroku("rake db:migrate") unless Kumade.configuration.pretending?
      Kumade.outputter.success("Migrated #{Kumade.configuration.environment}")
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
