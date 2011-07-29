class Kumade
  class Deployer
    def pre_deploy
      ensure_clean_git
      ensure_rake_passes
      package_assets
      git_push('origin')
    end

    def deploy_to(environment)
      ensure_heroku_remote_exists_for(environment)
      pre_deploy
      git_force_push(environment)
      heroku_migrate(environment)
    end

    def deploy_to_staging
      deploy_to(:staging)
    end

    def deploy_to_production
      deploy_to(:production)
    end

    def git_push(remote)
      run_or_raise("git push #{remote} master",
                   "Failed to push master -> #{remote}")
      announce "Pushed master -> #{remote}"
    end

    def git_force_push(remote)
      run_or_raise("git push -f #{remote} master",
                   "Failed to force push master -> #{remote}")
      announce "Force pushed master -> #{remote}"
    end

    def heroku_migrate(environment)
      app = Kumade.app_for(environment)

      run("bundle exec heroku rake db:migrate --app #{app}")
    end

    def ensure_clean_git
      if git_dirty?
        raise "Cannot deploy: repo is not clean."
      end
    end

    def ensure_rake_passes
      if default_task_exists?
        raise "Cannot deploy: tests did not pass" unless rake_succeeded?
      end
    end

    def package_assets
      package_with_jammit if jammit_installed?
      package_with_more if more_installed?
    end

    def package_with_jammit
      Jammit.package!
      announce("Successfully packaged with Jammit")
      if git_dirty?
        git_add_and_commit_all_assets_in(absolute_assets_path)
      end
    end

    def package_with_more
      Rake::Task['more:generate'].invoke
      if git_dirty?
        announce("Successfully packaged with More")

        git_add_and_commit_all_assets_in(more_assets_path)
      end
    end

    def git_add_and_commit_all_assets_in(dir)
      announce "Committing assets"
      run_or_raise("git add #{dir} && git commit -m 'Assets'",
                    "Cannot deploy: couldn't commit assets")
    end

    def git_add_and_commit_all_more_assets
      announce "Committing assets"
      run_or_raise("git add #{more_assets_path} && git commit -m 'Assets'",
                    "Cannot deploy: couldn't commit assets")
    end

    def absolute_assets_path
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
      Rake::Task.task_defined?('default')
    end

    def rake_succeeded?
      begin
        Rake::Task[:default].invoke
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

    def run_or_raise(command, error_message)
      raise(error_message) unless run(command)
    end

    def announce(message)
      puts message
    end

    def string_present?(maybe_string)
      maybe_string.is_a?(String) && maybe_string.size > 0
    end

    def ensure_heroku_remote_exists_for(environment)
      if remote_exists?(environment)
        if Kumade.app_for(environment)
          app_name = Kumade.app_for(environment)
          unless string_present?(app_name)
            raise %{Cannot deploy: "#{environment}" remote does not exist}
          end
        end
      else
        raise %{Cannot deploy: "#{environment}" remote does not exist}
      end
    end

    def remote_exists?(remote_name)
      `git remote`.split("\n").include?(remote_name)
    end
  end
end
