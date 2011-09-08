require 'spec_helper'

describe Kumade::CLI do
  subject { Kumade::CLI }
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

end

describe Kumade::CLI do
  it 'does not let anything get printed' do
    stdout = $stdout
    stdout.should_not_receive(:print)
    output = StringIO.new

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can't see me."
    end

    output.rewind
    output.read.should == "Hello, you can't see me.\n"
  end

  it 'dumps the output stash to real stdout when an error happens' do
    stdout = $stdout
    stdout.should_receive(:print)
    output = StringIO.new

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
      raise Kumade::DeploymentError.new("error")
    end
  end

  it 'prints everything in pretend mode' do
    stdout = $stdout
    stdout.should_receive(:puts)
    output = StringIO.new
    Kumade::CLI.should_receive(:pretending?).and_return(true)

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
    end
  end
end
