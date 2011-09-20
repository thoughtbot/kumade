require 'spec_helper'

describe Kumade::Heroku, "DEPLOY_BRANCH" do
  subject { Kumade::Heroku::DEPLOY_BRANCH }

  it { should == "deploy" }
end

describe Kumade::Heroku, "#sync" do
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
    subject.git.stubs(:create)
    subject.git.stubs(:push)
  end

  it "creates and pushes the deploy branch" do
    subject.sync

    subject.git.should have_received(:create).with("deploy")
    subject.git.should have_received(:push).with("deploy:master", environment, true)
  end
end

describe Kumade::Heroku, "#migrate_database" do
  let(:environment) { 'staging' }

  before do
    STDOUT.stubs(:puts)
    subject.stubs(:heroku)
    force_add_heroku_remote(environment)
  end

  it "runs db:migrate with the correct app" do
    subject.migrate_database

    subject.should have_received(:heroku).with("rake db:migrate")
  end

  context "when pretending" do
    before do
      STDOUT.stubs(:puts)
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.migrate_database

      subject.should have_received(:heroku).never
    end

    it "prints a message" do
      subject.migrate_database

      STDOUT.should have_received(:puts).with(regexp_matches(/Migrated #{environment}/))
    end
  end
end

describe Kumade::Heroku, "#heroku" do
  let(:command_line_instance) { stub("Cocaine::CommandLine instance", :run => true) }

  before do
    STDOUT.stubs(:puts)
  end

  context "when on Cedar" do
    include_context "when on Cedar"

    it "runs commands with `run`" do
      Cocaine::CommandLine.expects(:new).
        with(regexp_matches(/bundle exec heroku run/)).
        returns(command_line_instance)

      subject.heroku("rake")
    end
  end

  context "when not on Cedar" do
    include_context "when not on Cedar"

    it "runs commands without `run`" do
      Cocaine::CommandLine.expects(:new).
        with(regexp_matches(/bundle exec heroku rake/)).
        returns(command_line_instance)

      subject.heroku("rake")
    end
  end
end

describe Kumade::Heroku, "#cedar?" do
  context "when on Cedar" do
    include_context "when on Cedar"

    it "returns true" do
      subject.cedar?.should == true
    end
  end

  context "when not on Cedar" do
    include_context "when not on Cedar"

    it "returns false" do
      subject.cedar?.should == false
    end
  end
end

describe Kumade::Heroku, "#delete_deploy_branch" do
  before { STDOUT.stubs(:puts) }

  it "deletes the deploy branch" do
    Cocaine::CommandLine.expects(:new).
      with("git checkout master && git branch -D deploy").
      returns(stub(:run => true))

    subject.delete_deploy_branch
  end
end
