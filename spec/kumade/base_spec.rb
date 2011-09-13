require 'spec_helper'

describe Kumade::Base, "#success" do
  it { should respond_to(:success) }
end

describe Kumade::Base, "#error" do
  before { STDOUT.stubs(:puts) }

  it { should respond_to(:error) }

  it "prints its message and raises its message" do
    lambda { subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)

    STDOUT.should have_received(:puts).with(regexp_matches(/I'm an error!/))
  end
end

describe Kumade::Base, "#run_or_error" do
  let(:command)       { "dummy command" }
  let(:error_message) { "dummy error message" }

  before do
    STDOUT.stubs(:puts)
  end

  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
      subject.stubs(:run)
    end

    it "does not run the command" do
      subject.run_or_error("dummy command", "dummy error message")

      subject.should_not have_received(:run)
      STDOUT.should have_received(:puts).with(regexp_matches(/#{command}/))
    end
  end

  context "when not pretending" do
    context "when it runs successfully" do
      before do
        Cocaine::CommandLine.stubs(:new).returns(stub(:run))
      end

      it "does not print an error" do
        subject.run_or_error(command, error_message)

        STDOUT.should_not have_received(:puts).with(regexp_matches(/#{error_message}/))
      end
    end

    context "when it does not run successfully " do
      let(:failing_command_line) { stub("Failing Cocaine::CommandLine") }

      before do
        subject.stubs(:error)
        failing_command_line.stubs(:run).raises(Cocaine::ExitStatusError)
        Cocaine::CommandLine.stubs(:new).returns(failing_command_line)
      end

      it "prints an error message" do
        subject.run_or_error(command, error_message)

        subject.should have_received(:error).with(error_message)
      end
    end
  end
end

describe Kumade::Base, "#run" do
  let(:command_line) { stub("Cocaine::CommandLine") }
  let(:command)      { "command" }

  before do
    Cocaine::CommandLine.stubs(:new).with(command).returns(command_line)
  end

  context "when not successful" do
    before do
      command_line.stubs(:run)
    end

    it "returns true" do
      subject.run(command).should == true
    end
  end

  context "when successful" do
    before do
      command_line.stubs(:run).raises(Cocaine::ExitStatusError)
    end

    it "returns false" do
      subject.run(command).should == false
    end
  end
end

describe Kumade::Base, "#invoke_task" do
  before do
    STDOUT.stubs(:puts)
    Rake::Task.stubs(:[] => task)
  end
  
  let(:task) { stubs('task') }
  let(:task_name) { "kumade:before_asset_compilation" }
  
  it "calls deploy task when it exists" do
    subject.expects(:task_exist?).with(task_name).returns(true)
    Rake::Task.expects(:[]).with(task_name)
    task.expects(:invoke)
    subject.invoke_task(task_name)
  end
  it "should not calls deploy task when it doesn't exists" do
    subject.expects(:task_exist?).with(task_name).returns(false)
    Rake::Task.expects(:[]).never
    task.expects(:invoke).never
    subject.invoke_task(task_name)
  end
end

describe Kumade::Base, "#task_exist?" do
  before do
    Rake::Task.clear
  end
  
  it "should load Rakefile when it is available" do
    subject.expects(:load).with('Rakefile')
    File.expects(:exist?).with("Rakefile").returns(true)
    subject.task_exist?("kumade:before_asset_compilation")
  end

  it "should not load Rakefile when it isn't available" do
    subject.expects(:load).with('Rakefile').never
    File.expects(:exist?).with("Rakefile").returns(false)
    subject.task_exist?("kumade:before_asset_compilation")
  end

  it "returns true if it task found" do
    namespace :kumade do
      task :before_asset_compilation do

      end
    end
    Kumade::Base.new.task_exist?("kumade:before_asset_compilation").should be_true
  end

  it "returns false if task not found" do
    subject.task_exist?("kumade:before_asset_compilation").should be_false
  end
end