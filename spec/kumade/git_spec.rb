require 'spec_helper'

describe Kumade::Git, "#heroku_remote?" do
  context "when the environment is a Heroku repository" do
    let(:environment) { 'staging' }

    before do
      force_add_heroku_remote(environment)
      Kumade.configuration.environment = environment
    end

    after { remove_remote(environment) }

    its(:heroku_remote?) { should == true }
  end

  context "when the environment is a Heroku repository managed with heroku-accounts" do
    let(:another_heroku_environment) { 'another_staging' }
    let(:another_heroku_url)         { 'git@heroku.work:my-app.git' }

    before do
      force_add_heroku_remote(another_heroku_environment)
      Kumade.configuration.environment = another_heroku_environment
    end

    after { remove_remote(another_heroku_environment) }

    its(:heroku_remote?) { should == true }
  end

  context "when the environment is not a Heroku repository" do
    let(:not_a_heroku_env) { 'fake_heroku' }
    let(:not_a_heroku_url) { 'git@github.com:gabebw/kumade.git' }

    before do
      `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
      Kumade.configuration.environment = not_a_heroku_env
    end

    after { remove_remote(not_a_heroku_env) }

    its(:heroku_remote?) { should == false }
  end
end

describe Kumade::Git, ".environments" do
  let(:environment)      { 'staging' }
  let(:not_a_heroku_env) { 'fake_heroku' }
  let(:not_a_heroku_url) { 'git@github.com:gabebw/kumade.git' }

  before do
    force_add_heroku_remote(environment)
    `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
  end

  after do
    remove_remote(environment)
    remove_remote(not_a_heroku_env)
  end

  it "returns all Heroku environments" do
    Kumade::Git.environments.should == ["staging"]
  end
end

describe Kumade::Git, "#branch_exist?" do
  let(:command_line) { mock("Cocaine::CommandLine") }
  let(:branch)       { "branch" }

  before do
    command_line.stubs(:run)
    Cocaine::CommandLine.expects(:new).with("git show-ref #{branch}").returns(command_line)
  end

  it "returns true when the branch exists" do
    subject.branch_exist?("branch").should be_true

    command_line.should have_received(:run)
  end

  it "returns false if the branch doesn't exist" do
    command_line.stubs(:run).raises(Cocaine::ExitStatusError)

    subject.branch_exist?("branch").should be_false

    command_line.should have_received(:run)
  end
end

describe Kumade::Git, "#dirty?" do
  context "when dirty" do
    let(:failing_command_line) { mock("CommandLine instance") }

    before do
      failing_command_line.stubs(:run).raises(Cocaine::ExitStatusError)

      Cocaine::CommandLine.expects(:new).
        with("git diff --exit-code").
        returns(failing_command_line)
    end

    it "returns true" do
      subject.dirty?.should == true
    end
  end

  context "when clean" do
    before do
      Cocaine::CommandLine.expects(:new).
        with("git diff --exit-code").
        returns(stub("Successful CommandLine", :run => true))
    end

    it "returns false" do
      subject.dirty?.should == false
    end
  end
end
