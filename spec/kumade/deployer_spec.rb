require 'spec_helper'

describe Kumade::Deployer, "#pre_deploy", :with_mock_outputter do
  let(:git)              { subject.git }
  let(:rake_task_runner) { stub("RakeTaskRunner", :invoke => true) }
  let(:packager)         { stub("packager", :run => true) }

  before do
    Kumade::Packager.stubs(:new => packager)
    Kumade::RakeTaskRunner.stubs(:new).with("kumade:pre_deploy").returns(rake_task_runner)
  end

  it "calls the correct methods" do
    git.expects(:ensure_clean_git)
    subject.expects(:package_assets)
    git.expects(:push).with(subject.git.current_branch)

    subject.pre_deploy
  end

  it "invokes the kumade:pre_deploy task" do
    subject.pre_deploy

    Kumade::RakeTaskRunner.should have_received(:new).with("kumade:pre_deploy")
    rake_task_runner.should have_received(:invoke)
  end
end

describe Kumade::Deployer, "#post_deploy_success", :with_mock_outputter do
  let(:rake_task_runner) { stub("RakeTaskRunner", :invoke => true) }

  before do
    Kumade::RakeTaskRunner.stubs(:new).with("kumade:post_deploy").returns(rake_task_runner)
  end

  it "calls the correct methods" do
    subject.expects(:run_postdeploy_task)

    subject.post_deploy_success
  end

  it "invokes the kumade:post_deploy task" do
    subject.post_deploy_success

    Kumade::RakeTaskRunner.should have_received(:new).with("kumade:post_deploy")
    rake_task_runner.should have_received(:invoke)
  end
end

describe Kumade::Deployer, "#deploy", :with_mock_outputter do
  let(:remote_name) { 'staging' }

  before do
    force_add_heroku_remote(remote_name)
  end

  it "calls the correct methods" do
    subject.expects(:pre_deploy)
    subject.heroku.expects(:sync)
    subject.heroku.expects(:migrate_database)
    subject.heroku.expects(:restart_app)
    subject.expects(:post_deploy)
    subject.expects(:post_deploy_success)

    subject.deploy
  end

  context "if deploy fails" do
    before { subject.git.stubs(:heroku_remote?).raises(RuntimeError.new("fun times")) }

    it "calls post_deploy" do
      subject.expects(:post_deploy)
      subject.deploy
    end

    it "prints the error" do
      subject.deploy
      Kumade.configuration.outputter.should have_received(:error).with("RuntimeError: fun times")
    end
  end
end

describe Kumade::Deployer, "#sync_origin", :with_mock_outputter do
  let(:new_branch) { 'new-branch' }

  before do
    `git checkout -b #{new_branch} 2>/dev/null`
  end

  it "pushes the current branch to origin" do
    subject.git.expects(:push).with(new_branch)

    subject.sync_origin
  end
end

describe Kumade::Deployer, "#ensure_clean_git", :with_mock_outputter do
  it "calls git.ensure_clean_git" do
    subject.git.expects(:ensure_clean_git)
    subject.ensure_clean_git
  end
end

describe Kumade::Deployer, "#ensure_heroku_remote_exists", :with_mock_outputter do
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

describe Kumade::Deployer, "packaging", :with_mock_outputter do
  let(:git)      { stub("git", :current_branch => "awesome", :delete => true) }
  let(:packager) { stub("packager", :run => true) }

  before do
    Kumade::Git.stubs(:new => git)
    Kumade::Packager.stubs(:new => packager)
  end

  it "builds the correct packager" do
    subject.deploy
    Kumade::Packager.should have_received(:new).with(git)
  end
end
