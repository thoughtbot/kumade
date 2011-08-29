module Kumade
  class Deployer < Thor::Shell::Color
    DEPLOY_BRANCH = "deploy"
    attr_reader :environment, :pretending

    def initialize(environment = 'staging', pretending = false, cedar = false)
      super()
      @environment = environment
      @pretending  = pretending
      @branch      = current_branch
      @cedar       = cedar
      @git         = Git.new(pretending, environment)
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

    def sync_github
      @git.push(@branch)
    end

    def sync_heroku
      @git.create(DEPLOY_BRANCH)
      @git.push("#{DEPLOY_BRANCH}:master", environment, true)
    end

    def heroku_migrate
      app = Kumade.app_for(environment)

      heroku("rake db:migrate", app) unless pretending
      success("Migrated #{app}")
    end

    def post_deploy
      run_or_error(["git checkout #{@branch}", "git branch -D #{DEPLOY_BRANCH}"],
                   "Failed to clean up #{DEPLOY_BRANCH} branch")
    end

    def heroku(command, app)
      heroku_command = if @cedar
                         "bundle exec heroku run"
                       else
                         "bundle exec heroku"
                       end
      run_or_error("#{heroku_command} #{command} --app #{app}",
                   "Failed to run #{command} on Heroku")
    end

    def ensure_clean_git
      if ! pretending && git_dirty?
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    def package_assets
      invoke_custom_task  if custom_task?
      package_with_jammit if jammit_installed?
      package_with_more   if more_installed?
    end

    def package_with_jammit
      begin
        success_message = "Packaged assets with Jammit"

        if pretending
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
      if pretending
        success(success_message)
      else
        begin
          run "bundle exec rake more:generate"
          if git_dirty?
            success(success_message)
            git_add_and_commit_all_assets_in(more_assets_path)
          end
        rescue => more_error
          error("Error: #{more_error.class}: #{more_error.message}")
        end
      end
    end

    def invoke_custom_task
      success "Running kumade:before_asset_compilation task"
      Rake::Task["kumade:before_asset_compilation"].invoke unless pretending
    end

    def git_add_and_commit_all_assets_in(dir)
      run_or_error ["git checkout -b #{DEPLOY_BRANCH}", "git add -f #{dir}", "git commit -m 'Compiled assets'"],
                   "Cannot deploy: couldn't commit assets"

      success "Added and committed all assets"
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

    def custom_task?
      load("Rakefile") if File.exist?("Rakefile")
      Rake::Task.task_defined?("kumade:before_asset_compilation")
    end

    def git_dirty?
      `git diff --exit-code`
      !$?.success?
    end

    def run_or_error(commands, error_message)
      all_commands = [commands].flatten.join(' && ')
      if pretending
        say_status(:run, all_commands)
      else
        error(error_message) unless run(all_commands)
      end
    end

    def run(command, config = {})
      say_status :run, command
      config[:capture] ? `#{command}` : system("#{command}")
    end

    def error(message)
      say("==> ! #{message}", :red)
      exit 1
    end

    def success(message)
      say("==> #{message}", :green)
    end

    def ensure_heroku_remote_exists
      if remote_exists?(environment)
        if app_name = Kumade.app_for(environment)
          success("#{environment} is a Heroku remote")
        else
          error(%{Cannot deploy: "#{environment}" remote does not point to Heroku})
        end
      else
        error(%{Cannot deploy: "#{environment}" remote does not exist})
      end
    end

    def remote_exists?(remote_name)
      if pretending
        true
      else
        `git remote` =~ /^#{remote_name}$/
      end
    end

    def current_branch
      `git symbolic-ref HEAD`.sub("refs/heads/", "").strip
    end
  end
end
