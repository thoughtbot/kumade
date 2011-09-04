require 'spec_helper'

require 'jammit'

describe Kumade::Deployer, "#pre_deploy" do
  let(:git) { subject.git }

  it "calls the correct methods" do
    git.should_receive(:ensure_clean_git)
    subject.should_receive(:package_assets)
    git.should_receive(:push).with(subject.git.current_branch)

    subject.pre_deploy
  end
end

describe Kumade::Deployer, "#deploy" do
  let(:remote_name) { 'staging' }

  before do
    STDOUT.stub(:puts)
    force_add_heroku_remote(remote_name)
  end

  it "calls the correct methods" do
    subject.should_receive(:pre_deploy)
    subject.heroku.should_receive(:sync)
    subject.heroku.should_receive(:migrate_database)
    subject.should_receive(:post_deploy)

    subject.deploy
  end

  it "calls post_deploy if deploy fails" do
    subject.git.stub(:heroku_remote?).and_raise(RuntimeError)

    subject.should_receive(:post_deploy)

    subject.deploy
  end
end

describe Kumade::Deployer, "#sync_github" do
  let(:new_branch) { 'new-branch' }

  before do
    `git checkout -b #{new_branch}`
  end

  it "pushes the current branch to github" do
    subject.git.should_receive(:push).with(new_branch)

    subject.sync_github
  end
end

describe Kumade::Deployer, "#sync_heroku" do
  let(:environment) { 'my-env' }
  subject { Kumade::Deployer.new(environment) }
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  it "should call git.create and git.push" do
    git_mock.should_receive(:create).with("deploy")
    git_mock.should_receive(:push).with("deploy:master", environment, true)
    subject.sync_heroku
  end
end


describe Kumade::Deployer, "#ensure_clean_git" do
  it "calls git.ensure_clean_git" do
    subject.git.should_receive(:ensure_clean_git)
    subject.ensure_clean_git
  end
end

describe Kumade::Deployer, "#heroku_migrate" do
  let(:environment){ 'staging' }

  before do
    subject.stub(:say)
    force_add_heroku_remote(environment)
  end

  it "runs db:migrate with the correct app" do
    subject.stub(:run => true)
    subject.should_receive(:heroku).
      with("rake db:migrate")
    subject.should_receive(:success).with("Migrated staging")

    subject.post_deploy
  end
end

describe Kumade::Deployer, "#ensure_heroku_remote_exists" do
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
    Kumade.configuration.environment = environment
  end

  context "when the remote points to Heroku" do
    it "does not print an error" do
      STDOUT.should_not_receive(:puts).with(/==> !/)

      subject.ensure_heroku_remote_exists
    end

    it "prints a success message" do
      STDOUT.should_receive(:puts).with(/#{environment} is a Heroku remote/)

      subject.ensure_heroku_remote_exists
    end
  end

  context "when the remote does not exist" do
    before do
      remove_remote(environment)
    end

    it "prints an error" do
      STDOUT.should_receive(:puts).with(/Cannot deploy: "#{environment}" remote does not exist/)

      lambda { subject.ensure_heroku_remote_exists }.should raise_error(Kumade::DeploymentError)
    end
  end

  context "when the remote does not point to Heroku" do
    let(:bad_environment) { 'bad' }

    before do
      `git remote add #{bad_environment} blerg@example.com`
      Kumade.configuration.environment = bad_environment
    end

    it "prints an error" do
      STDOUT.should_receive(:puts).with(/Cannot deploy: "#{bad_environment}" remote does not point to Heroku/)

      lambda { subject.ensure_heroku_remote_exists }.should raise_error(Kumade::DeploymentError)
    end
  end
end
