require 'spec_helper'

describe Kumade::Runner do
  subject { Kumade::Runner }
  let(:out){ StringIO.new }
  let(:environment){ 'my-environment' }

  %w(-p --pretend).each do |pretend_arg|
    it "sets pretend mode when run with #{pretend_arg}" do
      subject.stub(:deploy)

      subject.run([environment, pretend_arg], out)
      subject.pretending?.should be_true
    end
  end

  it "defaults to staging" do
    subject.stub(:deploy)
    subject.run([], out)
    subject.environment.should == 'staging'
  end

  it "deploys" do
    Kumade::Deployer.any_instance.should_receive(:deploy)

    subject.run([environment], out)
  end
  
  it "should use cedar if git config environment stack is cedar" do
    `git config --add my-environment.stack "cedar"`
    deployer = double("deployer").as_null_object
    Kumade::Deployer.should_receive(:new).
      with(anything, anything, true).
      and_return(deployer)
    subject.run([environment], out)
    `git config --unset my-environment.stack "cedar"`
  end
  
  it "should not cedar if git config environment stack is defined" do
    `git config --unset my-environment.stack "cedar"`
    deployer = double("deployer").as_null_object
    Kumade::Deployer.should_receive(:new).
      with(anything, anything, false).
      and_return(deployer)
    subject.run([environment], out)
  end
end
