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

  %w(-c --cedar).each do |cedar_arg|
    it "uses cedar when run with #{cedar_arg}" do
      deployer = double("deployer").as_null_object
      Kumade::Deployer.should_receive(:new).
        with(anything, anything, true).
        and_return(deployer)

      subject.run([environment, cedar_arg], out)
    end
  end
end

describe Kumade::Runner do
  it 'does not let anything get printed' do
    stdout = $stdout
    stdout.should_not_receive(:print)
    output = StringIO.new

    Kumade::Runner.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can't see me."
    end

    output.rewind
    output.read.should == "Hello, you can't see me.\n"
  end

  it 'dumps the output stash to real stdout when an error happens' do
    stdout = $stdout
    stdout.should_receive(:print)
    output = StringIO.new

    Kumade::Runner.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
      raise Kumade::DeploymentError.new("error")
    end
  end

  it 'prints everything in pretend mode' do
    stdout = $stdout
    stdout.should_receive(:puts)
    output = StringIO.new
    Kumade::Runner.should_receive(:pretending?).and_return(true)

    Kumade::Runner.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
    end
  end
  it 'prints everything when verbose is true' do
    stdout = $stdout
    stdout.should_receive(:puts)
    output = StringIO.new
    Kumade::Runner.should_receive(:pretending?).and_return(false)
    Kumade::Runner.should_receive(:verbose?).and_return(true)

    Kumade::Runner.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
    end
  end
end
