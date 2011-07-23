class Kumade
  def self.deployer
    Deployer.new
  end

  class Deployer
    def load_tasks
      load 'kumade/tasks/deploy.rake'
    end

    def git_push(remote)
      system "git push #{remote} master"
    end
  end
end
