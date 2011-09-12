require 'spec_helper'

require 'jammit'

# This should really be done by mocking out a Heroku class
shared_context "when on Cedar" do
  let(:cocaine_mock) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.should_receive(:new).
      with("bundle exec heroku stack --remote staging").
      and_return(cocaine_mock)

    cocaine_mock.should_receive(:run).and_return(%{
  aspen-mri-1.8.6
  bamboo-mri-1.9.2
  bamboo-ree-1.8.7
* cedar (beta)
})
  end
end

shared_context "when not on Cedar" do
  let(:cocaine_mock) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.should_receive(:new).
      with("bundle exec heroku stack --remote staging").
      and_return(cocaine_mock)
    cocaine_mock.should_receive(:run).and_return(%{
  aspen-mri-1.8.6
* bamboo-mri-1.9.2
  bamboo-ree-1.8.7
  cedar (beta)
})
  end
end

describe Kumade::Deployer, "DEPLOY_BRANCH" do
  subject { Kumade::Deployer::DEPLOY_BRANCH }

  it { should == "deploy" }
end

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
    force_add_heroku_remote(remote_name)
  end

  it "calls the correct methods in order" do
    subject.stub(:run)
    subject.stub(:post_deploy)

    %w(ensure_heroku_remote_exists
       pre_deploy
       sync_heroku
       heroku_migrate
      ).each do |command|
      subject.should_receive(command).ordered
    end

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

  it "calls git.push with the current branch" do
    subject.git.should_receive(:push).with(new_branch)

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
  let(:environment) { 'staging' }

  before do
    force_add_heroku_remote(environment)
  end

  it "creates and pushes the deploy branch" do
    subject.git.should_receive(:create).with("deploy")
    subject.git.should_receive(:push).with("deploy:master", environment, true)
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
  let(:environment) { 'staging' }

  before do
    STDOUT.stub(:puts)
    force_add_heroku_remote(environment)
  end

  it "runs db:migrate with the correct app" do
    subject.should_receive(:heroku).with("rake db:migrate")

    subject.heroku_migrate
  end

  context "when pretending" do
    before do
      STDOUT.stub(:puts)
      Kumade.configuration.pretending = true
    end

    it "does not run heroku" do
      subject.should_not_receive(:heroku)
      subject.heroku_migrate
    end

    it "prints a message" do
      STDOUT.should_receive(:puts).with(/Migrated #{environment}/)

      subject.heroku_migrate
    end
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

describe Kumade::Deployer, "#cedar?" do
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

describe Kumade::Deployer, "#heroku" do
  before { STDOUT.stub(:puts) }

  context "when on Cedar" do
    include_context "when on Cedar"

    it "runs commands with `run`" do
      Cocaine::CommandLine.should_receive(:new).
        with(/bundle exec heroku run rake/).
        and_return(stub(:run => true))
      subject.heroku("rake")
    end
  end

  context "when not on Cedar" do
    include_context "when not on Cedar"

    it "runs commands without `run`" do
      Cocaine::CommandLine.should_receive(:new).
        with(/bundle exec heroku rake/).
        and_return(stub(:run => true))
      subject.heroku("rake")
    end
  end
end

describe Kumade::Deployer, "#post_deploy" do
  it "calls git.delete" do
    subject.git.should_receive(:delete).with('deploy', 'master')
    subject.post_deploy
  end
end
