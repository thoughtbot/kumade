require 'spec_helper'

describe Kumade::Deployer, "#pre_deploy" do
  before { subject.stub(:say) }

  it "calls the correct methods in order" do
    %w(
      ensure_clean_git
      package_assets
      sync_github
      ).each do |task|
      subject.should_receive(task).ordered.and_return(true)
    end

    subject.pre_deploy
  end

  it "syncs to github" do
    %w(
      ensure_clean_git
      package_assets
    ).each do |task|
      subject.stub(task)
    end

    subject.should_receive(:sync_github)
    subject.pre_deploy
  end
end

describe Kumade::Deployer, "#deploy" do
  let(:remote_name){ 'staging' }

  before do
    subject.stub(:say)
    force_add_heroku_remote(remote_name)
  end

  it "calls the correct methods in order" do
    subject.stub(:run => true)

    subject.should_receive(:ensure_heroku_remote_exists).
      ordered

    subject.should_receive(:pre_deploy).
      ordered.
      and_return(true)

    subject.should_receive(:sync_heroku).
      ordered.
      and_return(true)

    subject.should_receive(:heroku_migrate).
      ordered

    subject.should_receive(:post_deploy)

    subject.deploy
  end
end

describe Kumade::Deployer, "#sync_github" do
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  it "should call @git.push" do
    git_mock.should_receive(:push).with("master")
    subject.sync_github
  end
end

describe Kumade::Deployer, "#package_assets" do
  let(:packager_mock) { mock() }
  before { subject.stub(:packager => packager_mock) }
  it "should call @packager.run" do
    packager_mock.should_receive(:run)
    subject.package_assets
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
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  it "should call git.ensure_clean_git" do
    git_mock.should_receive(:ensure_clean_git)
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

    subject.heroku_migrate
  end
end

describe Kumade::Deployer, "#ensure_heroku_remote_exists" do
  let(:environment){ 'staging' }
  let(:bad_environment){ 'bad' }

  before do
    subject.stub(:say)
    force_add_heroku_remote(environment)
    `git remote add #{bad_environment} blerg@example.com`
  end

  context "when the remote points to Heroku" do
    subject { Kumade::Deployer.new(environment) }

    it "does not print an error" do
      subject.should_not_receive(:error)

      subject.ensure_heroku_remote_exists
    end

    it "prints a success message" do
      subject.should_receive(:success).with("#{environment} is a Heroku remote")

      subject.ensure_heroku_remote_exists
    end
  end


  context "when the remote does not exist" do
    subject { Kumade::Deployer.new(environment) }
    before { remove_remote(environment) }

    it "prints an error" do
      subject.should_receive(:error).with(%{Cannot deploy: "#{environment}" remote does not exist})

      subject.ensure_heroku_remote_exists
    end
  end

  context "when the remote does not point to Heroku" do
    subject { Kumade::Deployer.new(bad_environment) }

    it "prints an error" do
      subject.should_receive(:error).with(%{Cannot deploy: "#{bad_environment}" remote does not point to Heroku})

      subject.ensure_heroku_remote_exists
    end
  end
end

describe Kumade::Deployer, "#heroku" do
  context "when on Cedar" do
    subject { Kumade::Deployer.new('staging', false, cedar = true) }

    it "runs commands with `run`" do
      subject.should_receive(:run_or_error).with("bundle exec heroku run rake --remote staging", //)
      subject.heroku("rake")
    end
  end

  context "when not on Cedar" do
    subject { Kumade::Deployer.new('staging', false, cedar = false) }

    it "runs commands without `run`" do
      subject.should_receive(:run_or_error).with("bundle exec heroku rake --remote staging", //)
      subject.heroku("rake")
    end
  end
end

describe Kumade::Deployer, "#post_deploy" do
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  
  it "should call git.delete" do
    git_mock.should_receive(:delete).with('deploy', 'master')
    subject.post_deploy
  end

  it "prints its message and raises its message" do
    subject.should_receive(:say).with("==> ! I'm an error!", :red)
    lambda{ subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)
  end
end
