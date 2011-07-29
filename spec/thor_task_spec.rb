require 'spec_helper'

module Kumade
  describe ThorTask, "deploy" do
    before { subject.stub(:say) }

    it "calls the staging deploy method when called with staging" do
      Deployer.any_instance.should_receive(:deploy_to_staging)
      subject.deploy('staging')
    end

    it "calls the production deploy method when called with production" do
      Deployer.any_instance.should_receive(:deploy_to_production)
      subject.deploy('production')
    end
  end
end
