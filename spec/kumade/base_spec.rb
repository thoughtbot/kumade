require 'spec_helper'

describe Kumade::Base, "#success" do
  it "exists" do
    subject.should respond_to(:success)
  end
end

describe Kumade::Base, "#error" do
  it "exists" do
    subject.should respond_to(:error)
  end

  it "prints its message and raises its message" do
    subject.should_receive(:say).with("==> ! I'm an error!", :red)
    lambda{ subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)
  end
end

describe Kumade::Base, "#run_or_error" do
  let(:command) { "command" }
  let(:error_message) { "error_message" }
  
  before(:each) do
    subject.should_receive(:say_status).with(:run, command)
  end
  
  context "when pretending" do
    it "should never call run" do
      subject.should_receive(:pretending).and_return(true)
      subject.should_receive(:run).never
      subject.run_or_error(command, error_message)
    end
  end
  
  context "when not pretending" do

    before(:each) do
      subject.should_receive(:pretending).and_return(false)
    end

    context "with success" do
      it "should call not call error" do
        subject.should_receive(:run).and_return(true)
        subject.should_receive(:error).never
        subject.run_or_error(command, error_message)
      end
    end
    
    context "without success" do
      it "should call CommandLine.run and error with error_message" do
        subject.should_receive(:run).and_return(false)
        subject.should_receive(:error).with(error_message)
        subject.run_or_error(command, error_message)
      end
    end
  end
end

describe Kumade::Base, "#run" do
  let(:comand_line_mock) { mock("Cocaine::CommandLine") }
  let(:command) { "command" }
  
  before(:each) do
    Cocaine::CommandLine.should_receive(:new).with(command).and_return(comand_line_mock)
  end
  
  it "should return true when success" do
    comand_line_mock.should_receive(:run)
    subject.run(command).should be_true
  end
  
  it "should return false when not success" do
    comand_line_mock.should_receive(:run).and_raise(Cocaine::ExitStatusError)
    subject.run(command).should be_false
  end
end