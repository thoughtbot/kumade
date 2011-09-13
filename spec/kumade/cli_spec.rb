require 'spec_helper'

describe Kumade::CLI do
  let(:out)         { StringIO.new }
  let(:environment) { 'my-environment' }
  let(:deployer)          { stub("Deployer", :new => deployer_instance) }
  let(:deployer_instance) { stub("DeployerInstance", :deploy => nil) }

  before  { Kumade::CLI.deployer = deployer }
  after   { Kumade::CLI.deployer = nil }

  context "when pretending" do
    %w(-p --pretend).each do |pretend_flag|
      subject { Kumade::CLI.new([pretend_flag, environment], out) }

      context pretend_flag do
        it "sets pretending to true" do
          subject
          Kumade.configuration.pretending.should == true
        end

        it "deploys" do
          deployer_instance.expects(:deploy)
          subject
        end
      end
    end
  end

  context "with no command-line arguments" do
    subject { Kumade::CLI.new([], out) }

    it "sets the environment to staging" do
      Kumade.configuration.environment.should == 'staging'
    end

    it "sets pretending to false" do
      Kumade.configuration.pretending.should == false
    end
  end

  context "running normally" do
    subject { Kumade::CLI.new([environment], out) }

    it "sets pretending to false" do
      subject
      Kumade.configuration.pretending.should == false
    end

    it "deploys" do
      deployer_instance.expects(:deploy)
      subject
    end
  end
end

describe Kumade::CLI, ".deployer" do
  after { Kumade::CLI.deployer = nil }

  it "sets the deployer to the Deployer class by default" do
    Kumade::CLI.deployer.should == Kumade::Deployer
  end

  it "can override deployer" do
    Kumade::CLI.deployer = "deployer!"
    Kumade::CLI.deployer.should == "deployer!"
  end
end

describe Kumade::CLI, ".swapping_stdout_for" do
  let(:stdout) { $stdout }
  let(:output) { StringIO.new }

  it 'does not let anything get printed' do
    stdout.expects(:print).never

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can't see me."
    end

    output.rewind
    output.read.should == "Hello, you can't see me.\n"
  end

  it 'dumps the output stash to real stdout when an error happens' do
    stdout.expects(:print)

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
      raise Kumade::DeploymentError.new("error")
    end
  end

  context "in print output mode" do
    it 'prints everything' do
      stdout.expects(:puts)

      Kumade::CLI.swapping_stdout_for(output, true) do
        $stdout.puts "Hello, you can see me!"
      end
    end
  end
end
