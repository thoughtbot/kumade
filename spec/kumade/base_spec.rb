require 'spec_helper'

describe Kumade::Base, "#success" do
  it { should respond_to(:success) }
end

describe Kumade::Base, "#error" do
  it { should respond_to(:error) }

  it "prints its message and raises its message" do
    STDOUT.expects(:puts).with(regexp_matches(/I'm an error!/))

    lambda { subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)
  end
end

describe Kumade::Base, "#run_or_error" do
  let(:command)       { "dummy command" }
  let(:error_message) { "dummy error message" }

  before do
    STDOUT.expects(:puts).with(regexp_matches(/#{command}/))
  end

  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.expects(:run).never
      subject.run_or_error("dummy command", "dummy error message")
    end
  end

  context "when not pretending" do
    context "when it runs successfully" do
      it "does not print an error" do
        STDOUT.expects(:puts).with(regexp_matches(/#{error_message}/)).never
        Cocaine::CommandLine.stubs(:new).returns(stub(:run => true))

        subject.run_or_error(command, error_message)
      end
    end

    context "when it does not run successfully " do
      it "should call CommandLine.run and error with error_message" do
        subject.expects(:run).returns(false)
        subject.expects(:error).with(error_message)

        subject.run_or_error(command, error_message)
      end
    end
  end
end

describe Kumade::Base, "#run" do
  let(:command_line_mock) { mock("Cocaine::CommandLine") }
  let(:command)           { "command" }

  before do
    Cocaine::CommandLine.stubs(:new).with(command).returns(command_line_mock)
  end

  context "when not successful" do
    before do
      command_line_mock.expects(:run)
    end

    it "returns true" do
      subject.run(command).should == true
    end
  end

  context "when successful" do
    before do
      command_line_mock.expects(:run).raises(Cocaine::ExitStatusError)
    end

    it "returns false" do
      subject.run(command).should == false
    end
  end
end
