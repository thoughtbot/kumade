require 'spec_helper'

describe Kumade::Heroku, "DEPLOY_BRANCH", :with_mock_outputter do
  subject { Kumade::Heroku::DEPLOY_BRANCH }

  it { should == "deploy" }
end

describe Kumade::Heroku, "#pre_deploy", :with_mock_outputter do
  it "ensures heroku remote exists" do
    subject.expects(:ensure_heroku_remote_exists)
    subject.pre_deploy
  end
end

describe Kumade::Heroku, "#deploy", :with_mock_outputter do
  it "sync's and migrate's" do
    subject.expects(:sync)
    subject.expects(:migrate_database)
    subject.expects(:post_deploy)
    subject.deploy
  end

  it "calls post_deploy if the deploy fails", :with_mock_outputter do
    subject.stubs(:sync).raises(RuntimeError)
    subject.expects(:post_deploy)
    subject.deploy
  end

  it "reraises Kumade::DeploymentError's", :with_mock_outputter do 
    subject.stubs(:sync).raises("RuntimeError: fun times")
    subject.expects(:post_deploy)

    subject.deploy
    Kumade.configuration.outputter.should have_received(:error).with(regexp_matches(/RuntimeError: fun times/))
  end
end

describe Kumade::Heroku, "#post_deploy", :with_mock_outputter do
  it "deletes the deploy branch" do
    subject.expects(:delete_deploy_branch)
    subject.post_deploy
  end
end

describe Kumade::Heroku, "#ensure_heroku_remote_exists", :with_mock_outputter do
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
    Kumade.configuration.environment = environment
  end

  context "when the remote points to Heroku" do
    it "does not print an error" do
      subject.ensure_heroku_remote_exists

      Kumade.configuration.outputter.should have_received(:error).never
    end

    it "prints a success message" do
      subject.ensure_heroku_remote_exists

      Kumade.configuration.outputter.should have_received(:success).with(regexp_matches(/#{environment} is a Heroku remote/))
    end
  end

  context "when the remote does not exist" do
    before do
      remove_remote(environment)
    end

    it "prints an error" do
      subject.ensure_heroku_remote_exists

      Kumade.configuration.outputter.should have_received(:error).with(regexp_matches(/Cannot deploy: "#{environment}" remote does not exist/))
    end
  end

  context "when the remote does not point to Heroku" do
    let(:bad_environment) { 'bad' }

    before do
      `git remote add #{bad_environment} blerg@example.com`
      Kumade.configuration.environment = bad_environment
    end

    it "prints an error" do
      subject.ensure_heroku_remote_exists

      Kumade.configuration.outputter.should have_received(:error).with(regexp_matches(/Cannot deploy: "#{bad_environment}" remote does not point to Heroku/))
    end
  end
end

describe Kumade::Heroku, "#sync", :with_mock_outputter do
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

describe Kumade::Heroku, "#migrate_database", :with_mock_outputter do
  let(:environment) { 'staging' }

  before do
    subject.stubs(:heroku)
    force_add_heroku_remote(environment)
  end

  it "runs db:migrate with the correct app" do
    subject.migrate_database

    subject.should have_received(:heroku).with("rake db:migrate")
  end

  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
    end

    it "does not run the command" do
      subject.migrate_database

      subject.should have_received(:heroku).never
    end

    it "prints a message" do
      subject.migrate_database

      Kumade.configuration.outputter.should have_received(:success).with(regexp_matches(/Migrated #{environment}/))
    end
  end
end

describe Kumade::Heroku, "#heroku", :with_mock_outputter do
  let(:command_instance) { stub("Kumade::CommandLine instance", :run_or_error => true) }

  before do
    Kumade::CommandLine.stubs(:new => command_instance)
  end

  context "when on Cedar" do
    include_context "when on Cedar"

    it "runs commands with `run`" do
      subject.heroku("rake")

      Kumade::CommandLine.should have_received(:new).with(regexp_matches(/bundle exec heroku run rake/)).once
      command_instance.should have_received(:run_or_error).once
    end
  end

  context "when not on Cedar" do
    include_context "when not on Cedar"

    it "runs commands without `run`" do
      subject.heroku("rake")

      Kumade::CommandLine.should have_received(:new).with(regexp_matches(/bundle exec heroku rake/)).once
      command_instance.should have_received(:run_or_error).once
    end
  end
end

describe Kumade::Heroku, "#cedar?", :with_mock_outputter do
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

describe Kumade::Heroku, "#delete_deploy_branch", :with_mock_outputter do
  before { subject.git.stubs(:delete) }

  it "deletes the deploy branch" do
    subject.delete_deploy_branch

    subject.git.should have_received(:delete).with(Kumade::Heroku::DEPLOY_BRANCH, 'master').once
  end
end
