require 'spec_helper'

describe Kumade::Heroku, "DEPLOY_BRANCH" do
  subject { Kumade::Heroku::DEPLOY_BRANCH }

  it { should == "deploy" }
end

describe Kumade::Heroku, "#sync" do
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
  end

  it "creates and pushes the deploy branch" do
    subject.git.should_receive(:create).with("deploy")
    subject.git.should_receive(:push).with("deploy:master", environment, true)
    subject.sync
  end
end

describe Kumade::Heroku, "#migrate_database" do
  let(:environment) { 'staging' }

  before do
    STDOUT.stub(:puts)
    force_add_heroku_remote(environment)
  end

  it "runs db:migrate with the correct app" do
    subject.should_receive(:heroku).with("rake db:migrate")

    subject.migrate_database
  end

  context "when pretending" do
    before do
      STDOUT.stub(:puts)
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.should_not_receive(:heroku)

      subject.migrate_database
    end

    it "prints a message" do
      STDOUT.should_receive(:puts).with(/Migrated #{environment}/)

      subject.migrate_database
    end
  end
end

describe Kumade::Heroku, "#heroku" do
  let(:command_line_instance) { stub("Cocaine::CommandLine instance", :run => true) }

  before do
    STDOUT.stub(:puts)
  end

  context "when on Cedar" do
    include_context "when on Cedar"

    it "runs commands with `run`" do
      Cocaine::CommandLine.should_receive(:new).
        with(/bundle exec heroku run/).
        and_return(command_line_instance)

      subject.heroku("rake")
    end
  end

  context "when not on Cedar" do
    include_context "when not on Cedar"

    it "runs commands without `run`" do
      Cocaine::CommandLine.should_receive(:new).
        with(/bundle exec heroku rake/).
        and_return(command_line_instance)

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
  before { STDOUT.stub(:puts) }

  it "deletes the deploy branch" do
    Cocaine::CommandLine.should_receive(:new).
      with("git checkout master && git branch -D deploy").
      and_return(stub(:run => true))
    subject.delete_deploy_branch
  end
end

