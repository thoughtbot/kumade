require 'thor/shell'
require 'rake'

module Kumade
  class Deployer < Thor::Shell::Color
    DEPLOY_BRANCH = "deploy"
    attr_reader :pretending

    def initialize(pretending = false)
      super()
      @pretending = pretending
    end

    def deploy_to(environment)
      string_environment = environment.to_s
      ensure_heroku_remote_exists_for(string_environment)
      pre_deploy
      git_force_push(string_environment)
      heroku_migrate(string_environment)
      post_deploy
    end

    def pre_deploy
      ensure_clean_git
      ensure_rake_passes
      package_assets
      git_push('origin')
    end

    def git_push(remote)
      run_or_error("git push #{remote} master",
                  "Failed to push master -> #{remote}")
      success("Pushed master -> #{remote}")
    end

    def git_force_push(remote)
      run_or_error("git push -f #{remote} master",
                  "Failed to force push master -> #{remote}")
      success("Force pushed master -> #{remote}")
    end

    def heroku_migrate(environment)
      app = Kumade.app_for(environment)

      heroku("rake db:migrate", app)
      success("Migrated #{app}")
    end

    def post_deploy
      run_or_error("git checkout master", "git branch -D #{DEPLOY_BRANCH}",
                   "Failed to clean up #{DEPLOY_BRANCH} branch")
    end

    def heroku(command, app)
      heroku_command = if on_cedar?(app)
                         "bundle exec heroku run"
                       else
                         "bundle exec heroku"
                       end
      run_or_error("#{heroku_command} #{command} --app #{app}",
                   "Failed to run #{command} on Heroku")
    end

    def on_cedar?(app)
      selected_stack = `heroku stack --app '#{app}'`.split("\n").grep(/^\*/).first
      selected_stack && selected_stack.include?('cedar')
    end

    def ensure_clean_git
      if ! pretending && git_dirty?
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    def ensure_rake_passes
      if default_task_exists?
        if rake_succeeded?
          success("Rake passed")
        else
          error("Cannot deploy: tests did not pass")
        end
      end
    end

    def package_assets
      package_with_jammit if jammit_installed?
      package_with_more if more_installed?
    end

    def package_with_jammit
      begin
        success_message = "Packaged assets with Jammit"

        if pretending
          success(success_message)
        else
          Jammit.package!

          if git_dirty?
            success(success_message)
            git_add_and_commit_all_assets_in(jammit_assets_path)
          end
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

    def git_add_and_commit_all_assets_in(dir)
      run_or_error "git checkout -b #{DEPLOY_BRANCH}", "git add -f #{dir}", "git commit -m 'Assets'",
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

    def default_task_exists?
      `rake -s -P | grep 'rake default'`.strip.size > 0
    end

    def rake_succeeded?
      return true if pretending

      begin
        run "bundle exec rake"
      rescue
        false
      end
    end

    def git_dirty?
      git_changed = `git status --short 2> /dev/null | tail -n1`
      dirty = git_changed.size > 0
    end

    def run_or_error(*commands, error_message)
      all_commands = commands.join(' && ')
      if pretending
        say_status(:run, all_commands)
      else
        error(error_message) unless run(all_commands)
      end
    end

    def announce(message)
      say "==> #{message}"
    end

    def error(message)
      say("==> ! #{message}", :red)
      exit 1
    end

    def success(message)
      say("==> #{message}", :green)
    end

    def ensure_heroku_remote_exists_for(environment)
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
  end
end
