require 'spec_helper'

describe Kumade::CommandLine, "#run_or_error" do
  let(:command_line) { stub("Cocaine::CommandLine instance", :run => nil) }
  subject            { Kumade::CommandLine.new("echo") }

  before do
    subject.stubs(:error)
    subject.stubs(:say_status)

    Cocaine::CommandLine.stubs(:new).returns(command_line)
  end

  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.run_or_error

      command_line.should have_received(:run).never
    end
  end

  context "when successful" do
    before do
      Kumade.configuration.pretending = false
      command_line.stubs(:run => true)
    end

    it "returns true" do
      subject.run_or_error.should be_true
    end
  end

  context "when unsuccessful" do
    subject { Kumade::CommandLine.new("BAD COMMAND") }
    before do
      Kumade.configuration.pretending = false
    end

    it "prints an error message" do
      subject.run_or_error("something bad")

      subject.should have_received(:error).with("something bad")
    end
  end
end

describe Kumade::CommandLine, "#run_with_status" do
  let(:command)      { "echo" }
  let(:command_line) { stub("Cocaine::CommandLine instance", :run => nil, :command => command) }
  subject            { Kumade::CommandLine.new(command) }

  before do
    Cocaine::CommandLine.stubs(:new).returns(command_line)
    subject.stubs(:say_status)
  end

  it "prints the command" do
    subject.run_with_status

    subject.should have_received(:say_status).with(:run, "echo").once
  end

  context "when pretending" do
    before { Kumade.configuration.pretending = true }

    it "does not run the command" do
      subject.run_with_status

      command_line.should have_received(:run).never
    end

    it "returns true" do
      subject.run_with_status.should be_true
    end
  end

  context "when not pretending" do
    before { Kumade.configuration.pretending = false }

    it "runs the command" do
      subject.run_with_status

      command_line.should have_received(:run).once
    end
  end
end

describe Kumade::CommandLine, "#run" do
  context "when successful" do
    subject { Kumade::CommandLine.new("echo") }

    it "returns true" do
      subject.run.should == true
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
