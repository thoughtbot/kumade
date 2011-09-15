require 'spec_helper'

describe Kumade::Packager, ".available_packager" do
  let(:packager_1) { "1st packager" }
  let(:packager_2) { "2nd packager" }

  it "returns the first available packager" do
    Kumade::PackagerList.stubs(:new => [packager_1, packager_2])
    Kumade::Packager.available_packager.should == packager_1
  end

  it "returns nil if no packagers are availabke" do
    Kumade::PackagerList.stubs(:new => [])
    Kumade::Packager.available_packager.should be_nil
  end
end

describe Kumade::Packager, "#run" do
  let(:git)              { stub("git", :dirty? => true, :add_and_commit_all_in => true) }
  let(:packager)         { stub("packager", :name => "MyPackager", :package => true, :assets_path => 'fake_assets_path') }
  let(:rake_task_runner) { stub("RakeTaskRunner", :invoke => true) }

  before do
    Kumade::RakeTaskRunner.stubs(:new => rake_task_runner)
    subject.stubs(:success => nil, :error => nil)
  end

  subject { Kumade::Packager.new(git, packager) }

  it "precompiles assets" do
    subject.run
    Kumade::RakeTaskRunner.should have_received(:new).with("kumade:before_asset_compilation", subject)
    rake_task_runner.should have_received(:invoke)
  end

  context "when packaging with a packager" do
    context "when pretending" do
      before do
        Kumade.configuration.pretending = true
      end

      it "prints a success message" do
        subject.run
        subject.should have_received(:success).with("Packaged with MyPackager")
      end

      it "does not package" do
        subject.run
        packager.should have_received(:package).never
      end
    end

    context "when not pretending" do
      before do
        Kumade.configuration.pretending = false
      end

      it "prints a success message" do
        subject.run
        subject.should have_received(:success).with("Packaged with MyPackager")
      end

      it "packages" do
        subject.run
        packager.should have_received(:package).once
      end

      it "prints an error if an exception is raised" do
        packager.stubs(:package).raises(RuntimeError.new("my specific error"))
        subject.run
        subject.should have_received(:error).with("Error: RuntimeError: my specific error")
      end
    end
  end

  context "when packaging and the repository becomes dirty" do
    before do
      Kumade.configuration.pretending = false
      git.stubs(:dirty? => true)
    end

    it "performs a commit" do
      subject.run
      git.should have_received(:add_and_commit_all_in).
        with(packager.assets_path,
             Kumade::Heroku::DEPLOY_BRANCH,
             'Compiled assets',
             "Added and committed all assets",
             "couldn't commit assets")
    end

    it "prints the success message after committing" do
      git.stubs(:add_and_commit_all_in).raises(RuntimeError.new("something broke"))
      subject.run
      subject.should have_received(:success).never
    end
  end

  context "when packaging and the repository is not dirty" do
    before do
      Kumade.configuration.pretending = false
      git.stubs(:dirty? => false)
    end

    it "does not print a success message" do
      subject.run
      subject.should have_received(:success).never
    end

    it "doesn't perform a commit" do
      subject.run
      git.should have_received(:add_and_commit_all_in).never
    end
  end
end
