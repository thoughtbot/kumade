class Kumade
  class Deployer
    def load_tasks
      load 'kumade/tasks/deploy.rake'
    end

    def pre_deploy
      ensure_clean_git
      ensure_rake_passes
      git_push('origin')
    end

    def deploy_to_staging
      pre_deploy
      git_force_push('staging')
    end

    def deploy_to_production
      pre_deploy
      git_force_push('production')
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
  end
end
