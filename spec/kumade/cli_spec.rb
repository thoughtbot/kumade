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
      context pretend_flag do
        subject { Kumade::CLI.new([pretend_flag, environment], out) }

        it "deploys correctly" do
          deployer.should_receive(:new).with(environment, true, true)
          deployer_instance.should_receive(:deploy)
          subject
        end
      end
    end
  end

  context "running normally" do
    subject { Kumade::CLI.new([environment], out) }

    it "deploys correctly" do
      deployer.should_receive(:new).with(environment, false, true)
      deployer_instance.should_receive(:deploy)
      subject
    end
    
    it "should not run tests if git config environment tests is false" do
      `git config --add my-environment.tests "false"`
      deployer.should_receive(:new).with(environment, false, false)
      deployer_instance.should_receive(:deploy)
      subject
      `git config --unset my-environment.stack "cedar"`
    end
  end
end

describe Kumade::CLI, ".deployer" do
  after { Kumade::CLI.deployer = nil }
  it    { Kumade::CLI.deployer.should == Kumade::Deployer }

  it "can override deployer" do
    Kumade::CLI.deployer = "deployer!"
    Kumade::CLI.deployer.should == "deployer!"
  end
end

describe Kumade::CLI, ".swapping_stdout_for" do
  let(:stdout) { $stdout }
  let(:output) { StringIO.new }

  it 'does not let anything get printed' do
    stdout.should_not_receive(:print)

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can't see me."
    end

    output.rewind
    output.read.should == "Hello, you can't see me.\n"
  end

  it 'dumps the output stash to real stdout when an error happens' do
    stdout.should_receive(:print)

    Kumade::CLI.swapping_stdout_for(output) do
      $stdout.puts "Hello, you can see me!"
      raise Kumade::DeploymentError.new("error")
    end
  end

  context "in pretend mode" do
    it 'prints everything' do
      stdout.should_receive(:puts)

      Kumade::CLI.swapping_stdout_for(output, true) do
        $stdout.puts "Hello, you can see me!"
      end
    end
  end
end
