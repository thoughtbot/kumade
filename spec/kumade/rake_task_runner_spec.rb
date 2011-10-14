require "spec_helper"

describe Kumade::RakeTaskRunner, :with_mock_outputter do
  context "when the task doesn't exist" do
    subject { Kumade::RakeTaskRunner.new("bogus:task") }

    it "does not notify the user that the task was run successfully" do
      subject.invoke
      Kumade.configuration.outputter.should have_received(:success).never
    end
  end

  context "when Rakefile exists" do
    subject { Kumade::RakeTaskRunner.new("bogus:task") }

    before do
      File.stubs(:exist?).with("Rakefile").returns(true)
    end

    it "loads the Rakefile" do
      subject.stubs(:load).with("Rakefile")
      subject.invoke
      subject.should have_received(:load).with("Rakefile")
    end
  end

  context "when the task exists" do
    let(:task_name)    { "kumade:test:custom_task_name" }
    let(:invoked_task) { stub("invoked", :invoke! => false) }

    before do
      Rake::Task.define_task task_name do
        invoked_task.invoke!
      end
    end

    after do
      Rake::Task[task_name].reenable
    end

    subject { Kumade::RakeTaskRunner.new(task_name) }

    context "when pretending" do
      before do
        Kumade.configuration.pretending = true
      end

      it "notifies the user that the task was run successfully" do
        subject.invoke
        Kumade.configuration.outputter.should have_received(:success).with("Running rake task: #{task_name}")
      end

      it "does not invoke the task" do
        subject.invoke
        invoked_task.should have_received(:invoke!).never
      end
    end

    context "when not pretending" do
      before do
        Kumade.configuration.pretending = false
      end

      it "notifies the user that the task was run successfully" do
        subject.invoke
        Kumade.configuration.outputter.should have_received(:success).with("Running rake task: #{task_name}")
      end

      it "invokes the task" do
        subject.invoke
        invoked_task.should have_received(:invoke!).once
      end
    end
  end
end
