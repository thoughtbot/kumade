require 'spec_helper'

class Kumade
  describe Deployer, "load_tasks" do
    it "loads the deploy tasks" do
      Rake.application.tasks.should be_empty
      subject.load_tasks
      task_names = Rake.application.tasks.map{|task| task.name }
      %w(deploy deploy:production deploy:staging).each do |expected_name|
        task_names.should include expected_name
      end
    end
  end
end
