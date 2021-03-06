require 'spec_helper'

describe Kumade::CommandLine, "#run_or_error", :with_mock_outputter do
  subject { Kumade::CommandLine.new("echo") }

  context "when pretending" do
    let(:command_line) { stub("Cocaine::CommandLine instance", :run => "does-not-matter", :command => 'command') }

    before do
      Cocaine::CommandLine.stubs(:new).returns(command_line)
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.run_or_error

      command_line.should have_received(:run).never
    end

    it "prints the command" do
      subject.run_or_error
      Kumade.configuration.outputter.should have_received(:say_command).with(command_line.command).once
    end
  end

  context "when successful" do
    let(:command_line)        { stub("Cocaine::CommandLine instance", :run => command_line_result, :command => 'command') }
    let(:command_line_result) { "result" }

    before do
      Cocaine::CommandLine.stubs(:new).returns(command_line)
      Kumade.configuration.pretending = false
    end

    it "returns the result of running the command" do
      subject.run_or_error.should == command_line_result
    end
  end

  context "when unsuccessful" do
    subject { Kumade::CommandLine.new("BAD COMMAND") }
    before do
      Kumade.configuration.pretending = false
    end

    it "prints an error message" do
      subject.run_or_error("something bad")

      Kumade.configuration.outputter.should have_received(:error).with("something bad")
    end
  end
end

describe Kumade::CommandLine, "#run_with_status", :with_mock_outputter do
  let(:command)      { "echo blah" }
  let(:command_line_result) { "blah\n" }
  let(:command_line) { stub("Cocaine::CommandLine instance", :run => command_line_result, :command => command) }
  subject            { Kumade::CommandLine.new(command) }

  before do
    Cocaine::CommandLine.stubs(:new).returns(command_line)
  end

  it "prints the command" do
    subject.run_with_status

    Kumade.configuration.outputter.should have_received(:say_command).with(command).once
  end

  context "when pretending" do
    before { Kumade.configuration.pretending = true }

    it "does not run the command" do
      subject.run_with_status

      command_line.should have_received(:run).never
    end

    it "returns true" do
      subject.run_with_status.should == true
    end
  end

  context "when not pretending" do
    before { Kumade.configuration.pretending = false }

    it "runs the command" do
      subject.run_with_status

      command_line.should have_received(:run).once
    end

    it "returns the result of running the command" do
      subject.run_with_status.should == command_line_result
    end
  end
end

describe Kumade::CommandLine, "#run", :with_mock_outputter do
  context "when successful" do
    subject { Kumade::CommandLine.new("echo -n blah") }

    it "returns the result of running the command" do
      subject.run.should == "blah"
    end
  end

  context "when unsuccessful" do
    let(:bad_command) { "grep FAKE NOT_A_FILE" }
    subject           { Kumade::CommandLine.new("#{bad_command} 2>/dev/null") }

    it "returns false" do
      subject.run.should be_false
    end
  end
end
