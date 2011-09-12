require "rake"
require 'cocaine'

module Kumade
  class Deployer < Base
    DEPLOY_BRANCH = "deploy"
    attr_reader :git

    def initialize
      super()
      @git    = Git.new
      @branch = @git.current_branch
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
      if Kumade.configuration.tests?
        run_tests
      end
      package_assets
      sync_github
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

    def package_assets
      invoke_task("kumade:before_asset_compilation")
      package_with_jammit if jammit_installed?
      package_with_more   if more_installed?
    end
    
    def run_tests
      %w(spec
        test
        features
        cucumber
      ).each {|task| invoke_task(task)}
    end

    def package_with_jammit
      begin
        success_message = "Packaged assets with Jammit"

        if Kumade.configuration.pretending?
          success(success_message)
        else
          Jammit.package!

          success(success_message)
          git_add_and_commit_all_assets_in(jammit_assets_path)
        end
      rescue => jammit_error
        error("Error: #{jammit_error.class}: #{jammit_error.message}")
      end
    end

    def package_with_more
      success_message = "Packaged assets with More"
      if Kumade.configuration.pretending?
        success(success_message)
      else
        begin
          run "bundle exec rake more:generate"
          if git.dirty?
            success(success_message)
            git_add_and_commit_all_assets_in(more_assets_path)
          end
        rescue => more_error
          error("Error: #{more_error.class}: #{more_error.message}")
        end
      end
    end

    def invoke_task(task)
      if task_exist?(task)
        success "Running #{task} task"
        Rake::Task[task].invoke unless Kumade.configuration.pretending?
      end
    end

    def git_add_and_commit_all_assets_in(dir)
      git.add_and_commit_all_in(dir, DEPLOY_BRANCH, 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    end

    def jammit_assets_path
      File.join(Jammit::PUBLIC_ROOT, Jammit.package_path)
    end

    def more_assets_path
      File.join('public', ::Less::More.destination_path)
    end

    def jammit_installed?
      @jammit_installed ||=
        (defined?(Jammit) ||
          begin
            require 'jammit'
            true
          rescue LoadError
            false
          end)
    end

    def more_installed?
      @more_installed ||=
        (defined?(Less::More) ||
          begin
            require 'less/more'
            true
          rescue LoadError
            false
          end)
    end

    def task_exist?(task)
      load("Rakefile") if File.exist?("Rakefile")
      Rake::Task.task_defined?(task)
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
