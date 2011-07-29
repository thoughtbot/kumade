require 'thor/shell'
require 'rake'

module Kumade
  class Deployer < Thor::Shell::Color
    attr_reader :pretending

    def initialize(pretending = false)
      super()
      @pretending = !!pretending
    end

    def pre_deploy
      ensure_clean_git
      ensure_rake_passes
      package_assets
      git_push('origin')
    end

    def deploy_to(environment)
      string_environment = environment.to_s
      ensure_heroku_remote_exists_for(string_environment)
      pre_deploy
      git_force_push(string_environment)
      heroku_migrate(string_environment)
    end

    def git_push(remote)
      unless pretending
        run_or_error("git push #{remote} master",
                    "Failed to push master -> #{remote}")
      end
      success("Pushed master -> #{remote}")
    end

    def git_force_push(remote)
      unless pretending
        run_or_error("git push -f #{remote} master",
                    "Failed to force push master -> #{remote}")
      end
      success("Force pushed master -> #{remote}")
    end

    def heroku_migrate(environment)
      app = Kumade.app_for(environment)

      unless pretending
        heroku("rake db:migrate", app)
      end
      success("Migrated #{app}")
    end

    def heroku(command, app)
      heroku_command = if on_cedar?(app)
                         "bundle exec heroku run"
                       else
                         "bundle exec heroku"
                       end
      run("#{heroku_command} #{command} --app #{app}")
    end

    def on_cedar?(app)
      `heroku stack --app '#{app}'`.grep(/^\*/).first.include?('cedar')
    end

    def ensure_clean_git
      if git_dirty? && ! pretending
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    def ensure_rake_passes
      if default_task_exists?
        if pretending || rake_succeeded?
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
      begin
        system "bundle exec rake more:generate"
        if git_dirty?
          success("Packaged assets with More")

          git_add_and_commit_all_assets_in(more_assets_path)
        end
      rescue => more_error
        error("Error: #{more_error.class}: #{more_error.message}")
      end
    end

    def git_add_and_commit_all_assets_in(dir)
      run_or_error("git add #{dir} && git commit -m 'Assets'",
                    "Cannot deploy: couldn't commit assets")

      success("Added and committed all assets")
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
          rescue LoadError
            false
          end)
    end

    def more_installed?
      @more_installed ||=
        (defined?(Less::More) ||
          begin
            require 'less/more'
          rescue LoadError
            false
          end)
    end

    def default_task_exists?
      `rake -s -P | grep 'rake default'`.strip.size > 0
    end

    def rake_succeeded?
      begin
        system "bundle exec rake"
      rescue
        false
      end
    end

    def git_dirty?
      git_changed = `git status --short 2> /dev/null | tail -n1`
      dirty = git_changed.size > 0
    end

    def run(command)
      announce "+ #{command}"
      announce "- #{system command}"
      $?.success?
    end

    def run_or_error(command, error_message)
      if ! pretending
        unless run(command)
          error(error_message)
        end
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

    def string_present?(maybe_string)
      maybe_string.is_a?(String) && maybe_string.size > 0
    end

    def ensure_heroku_remote_exists_for(environment)
      if remote_exists?(environment)
        if Kumade.app_for(environment)
          app_name = Kumade.app_for(environment)
          if string_present?(app_name)
            success("#{environment} is a Heroku remote")
          else
            error(%{Cannot deploy: "#{environment}" remote does not point to Heroku})
          end
        end
      else
        error(%{Cannot deploy: "#{environment}" remote does not exist})
      end
    end

    def remote_exists?(remote_name)
      if pretending
        true
      else
        `git remote`.split("\n").include?(remote_name)
      end
    end
  end
end
