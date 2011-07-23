require 'kumade/deployer'

class Kumade
  def self.load_tasks
    Deployer.new.load_tasks
  end

  def self.ensure_clean_git
    if git_dirty?
      raise "Cannot deploy: repo is not clean."
    end
  end

  def self.ensure_rake_passes
    if default_task_exists?
      rake_succeeded = system "rake"
      raise "Cannot deploy: tests did not pass" unless rake_succeeded
    end
  end

  def self.default_task_exists?
    Rake::Task.task_defined?('default')
  end

  def self.git_dirty?
    git_changed = `git status --short 2> /dev/null | tail -n1`
    puts git_changed
    dirty = git_changed.size > 0
  end
end
