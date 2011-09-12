require 'spec_helper'

describe Kumade::Base, "#success" do
  it { should respond_to(:success) }
end

describe Kumade::Base, "#error" do
  it { should respond_to(:error) }

  it "prints its message and raises its message" do
    STDOUT.should_receive(:puts).with(/I'm an error!/)

    lambda { subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)
  end
end

describe Kumade::Base, "#run_or_error" do
  let(:command)       { "dummy command" }
  let(:error_message) { "dummy error message" }

  before do
    STDOUT.should_receive(:puts).with(/#{command}/)
  end

  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.should_not_receive(:run)
      subject.run_or_error("dummy command", "dummy error message")
    end
  end

  context "when not pretending" do
    context "when it runs successfully" do
      it "does not print an error" do
        STDOUT.should_not_receive(:puts).with(/#{error_message}/)
        Cocaine::CommandLine.stub(:new).and_return(stub(:run => true))

        subject.run_or_error(command, error_message)
      end
    end

    context "when it does not run successfully " do
      it "should call CommandLine.run and error with error_message" do
        subject.should_receive(:run).and_return(false)
        subject.should_receive(:error).with(error_message)

        subject.run_or_error(command, error_message)
      end
    end
  end
end

describe Kumade::Base, "#run" do
  let(:command_line_mock) { mock("Cocaine::CommandLine") }
  let(:command)           { "command" }

  before do
    Cocaine::CommandLine.stub(:new).with(command).and_return(command_line_mock)
  end

  context "when not successful" do
    before do
      command_line_mock.should_receive(:run)
    end

    it "returns true" do
      subject.run(command).should == true
    end
  end

  context "when successful" do
    before do
      command_line_mock.should_receive(:run).and_raise(Cocaine::ExitStatusError)
    end

    it "returns false" do
      subject.run(command).should == false
    end
  end
end
