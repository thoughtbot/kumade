require 'spec_helper'

module Kumade
  describe ThorTask, "deploy" do
    before { subject.stub(:say) }

    let(:environment){ 'bamboo' }

    it "calls the deploy method with the correct environment" do
      Deployer.any_instance.should_receive(:deploy_to).with(environment)
      subject.deploy(environment)
    end
  end
end
