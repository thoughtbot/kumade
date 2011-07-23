class Kumade
  class Deployer
    def load_tasks
      load 'kumade/tasks/deploy.rake'
    end

    def git_push(remote)
      run_or_raise("git push #{remote} master",
                   "Failed to push master -> #{remote}")
      puts "Pushed master -> #{remote}"
    end

    def git_force_push(remote)
      run_or_raise("git push -f #{remote} master",
                   "Failed to force push master -> #{remote}")
      puts "Force pushed master -> #{remote}"
    end

    def ensure_clean_git
      if git_dirty?
        raise "Cannot deploy: repo is not clean."
      end
    end

    def ensure_rake_passes
      if default_task_exists?
        rake_succeeded = system "rake"
        raise "Cannot deploy: tests did not pass" unless rake_succeeded
      end
    end

    def default_task_exists?
      Rake::Task.task_defined?('default')
    end

    def git_dirty?
      git_changed = `git status --short 2> /dev/null | tail -n1`
      dirty = git_changed.size > 0
    end

    def run(command)
      puts "+ #{command}"
      puts "- #{system command}"
      $?.success?
    end

    def run_or_raise(command, error_message)
      raise(error_message) unless run(command)
    end
  end
end
