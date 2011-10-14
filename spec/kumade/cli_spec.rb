require 'spec_helper'

describe Kumade::CLI, :with_mock_outputter do
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
          Kumade.configuration.should be_pretending
        end

        it "deploys" do
          subject

          deployer_instance.should have_received(:deploy)
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
      Kumade.configuration.should_not be_pretending
    end
  end

  context "running normally" do
    subject { Kumade::CLI.new([environment], out) }

    it "sets pretending to false" do
      subject
      Kumade.configuration.should_not be_pretending
    end

    it "deploys" do
      subject

      deployer_instance.should have_received(:deploy)
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

  before do
    stdout.stubs(:print => nil, :puts => nil)
  end

  it 'does not let anything get printed' do
    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can't see me."
    end

    stdout.should have_received(:print).never

    output.rewind
    output.read.should == "Hello, you can't see me.\n"
  end

  it 'dumps the output stash to real stdout when an error happens' do
    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
      raise Kumade::DeploymentError.new("error")
    end

    stdout.should have_received(:print)
  end

  context "in print output mode" do
    it 'prints everything' do
      Kumade::CLI.swapping_stdout_for(output, true) do
        $stdout.puts "Hello, you can see me!"
      end

      stdout.should have_received(:puts)
    end
  end
end
