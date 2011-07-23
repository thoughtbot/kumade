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

  def self.git_dirty?
    git_changed = `git status --short 2> /dev/null | tail -n1`
    puts git_changed
    dirty = git_changed.size > 0
  end
end
