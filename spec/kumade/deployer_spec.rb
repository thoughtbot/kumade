require 'spec_helper'

require 'jammit'

describe Kumade::Deployer, "#pre_deploy" do
  let(:git) { subject.git }

  it "calls the correct methods" do
    git.expects(:ensure_clean_git)
    subject.expects(:package_assets)
    git.expects(:push).with(subject.git.current_branch)

    subject.pre_deploy
  end
end

describe Kumade::Deployer, "#deploy" do
  let(:remote_name) { 'staging' }

  before do
    STDOUT.stubs(:puts)
    force_add_heroku_remote(remote_name)
  end

  it "calls the correct methods" do
    subject.expects(:pre_deploy)
    subject.heroku.expects(:sync)
    subject.heroku.expects(:migrate_database)
    subject.expects(:post_deploy)

    subject.deploy
  end

  it "calls post_deploy if deploy fails" do
    subject.git.stubs(:heroku_remote?).raises(RuntimeError)

    subject.expects(:post_deploy)

    subject.deploy
  end
end

describe Kumade::Deployer, "#sync_github" do
  let(:new_branch) { 'new-branch' }

  before do
    `git checkout -b #{new_branch}`
  end

  it "pushes the current branch to github" do
    subject.git.expects(:push).with(new_branch)

    subject.sync_github
  end
end

describe Kumade::Deployer, "#ensure_clean_git" do
  it "calls git.ensure_clean_git" do
    subject.git.expects(:ensure_clean_git)
    subject.ensure_clean_git
  end
end

describe Kumade::Deployer, "#ensure_heroku_remote_exists" do
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
    Kumade.configuration.environment = environment
  end

  context "when the remote points to Heroku" do
    before { STDOUT.stubs(:puts) }

    it "does not print an error" do
      subject.ensure_heroku_remote_exists

      STDOUT.should_not have_received(:puts).with(regexp_matches(/==> !/))
    end

    it "prints a success message" do
      subject.ensure_heroku_remote_exists

      STDOUT.should have_received(:puts).with(regexp_matches(/#{environment} is a Heroku remote/))
    end
  end

  context "when the remote does not exist" do
    before do
      remove_remote(environment)
      STDOUT.stubs(:puts)
    end

    it "prints an error" do
      lambda { subject.ensure_heroku_remote_exists }.should raise_error(Kumade::DeploymentError)

      STDOUT.should have_received(:puts).with(regexp_matches(/Cannot deploy: "#{environment}" remote does not exist/))
    end
  end

  context "when the remote does not point to Heroku" do
    let(:bad_environment) { 'bad' }

    before do
      `git remote add #{bad_environment} blerg@example.com`
      STDOUT.stubs(:puts)
      Kumade.configuration.environment = bad_environment
    end

    it "prints an error" do
      lambda { subject.ensure_heroku_remote_exists }.should raise_error(Kumade::DeploymentError)

      STDOUT.should have_received(:puts).with(regexp_matches(/Cannot deploy: "#{bad_environment}" remote does not point to Heroku/))
    end
  end
end
