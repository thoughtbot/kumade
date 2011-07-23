require 'kumade/deployer'

class Kumade
  def self.load_tasks
    deployer.load_tasks
  end

  def self.deployer
    @deployer ||= Deployer.new
  end
end
