class Kumade
  def self.deployer
    Deployer.new
  end

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
