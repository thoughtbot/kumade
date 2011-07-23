require 'kumade/deployer'

class Kumade
  def self.load_tasks
    Deployer.new.load_tasks
  end
end
