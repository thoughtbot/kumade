require 'spec_helper'

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
  it "calls the correct methods" do
    subject.heroku.expects(:pre_deploy)
    subject.expects(:pre_deploy)
    subject.heroku.expects(:deploy)

    subject.deploy
  end
end

describe Kumade::Deployer, "#sync_origin" do
  let(:new_branch) { 'new-branch' }

  before do
    `git checkout -b #{new_branch}`
  end

  it "pushes the current branch to origin" do
    subject.git.expects(:push).with(new_branch)

    subject.sync_origin
  end
end

describe Kumade::Deployer, "#ensure_clean_git" do
  it "calls git.ensure_clean_git" do
    subject.git.expects(:ensure_clean_git)
    subject.ensure_clean_git
  end
end

describe Kumade::Deployer, "packaging" do
  let(:git)      { stub_everything("git") }
  let(:heroku)   { stub_everything("heroku") }
  let(:packager) { stub_everything("packager") }

  before do
    Kumade::Git.stubs(:new => git)
    Kumade::Heroku.stubs(:new => heroku)
    Kumade::Packager.stubs(:new => packager)
  end

  it "builds the correct packager" do
    subject.deploy
    Kumade::Packager.should have_received(:new).with(git)
  end
end
