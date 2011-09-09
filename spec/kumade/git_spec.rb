require 'spec_helper'

describe Kumade::Git, "#heroku_remote?" do
  let(:environment)                { 'staging' }
  let(:another_heroku_environment) { 'another_staging' }
  let(:not_a_heroku_env)           { 'fake_heroku' }
  let(:not_a_heroku_url)           { 'git@github.com:gabebw/kumade.git' }
  let(:another_heroku_url)         { 'git@heroku.work:my-app.git' }

  before do
    force_add_heroku_remote(environment)
    `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
    `git remote add #{another_heroku_environment} #{another_heroku_url}`
  end

  after do
    remove_remote(environment)
    remove_remote(not_a_heroku_env)
    remove_remote(another_heroku_environment)
  end

  it "returns true when the remote is a heroku repository" do
    Kumade::Git.new(false, environment).heroku_remote?.should be_true
    Kumade::Git.new(false, another_heroku_environment).heroku_remote?.should be_true
  end

  it "returns false when the remote is not a heroku repository" do
    Kumade::Git.new(false, 'kumade').heroku_remote?.should be_false
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

  it "returns all environments" do
    Kumade::Git.environments.should == ["staging"]
  end
end

describe Kumade::Git, "#branch_exist?" do
  let(:comand_line_mock) { mock("Cocaine::CommandLine") }
  let(:branch) { "branch" }
  let(:environment) { "staging" }
  
  subject { Kumade::Git.new(false, environment) }

  before(:each) do
    Cocaine::CommandLine.should_receive(:new).with("git show-ref #{branch}").and_return(comand_line_mock)
  end
  
  it "should return true when branch exist" do
    comand_line_mock.should_receive(:run)
    subject.branch_exist?("branch").should be_true
  end
  
  it "should return false if branch doesn't exist" do
    comand_line_mock.should_receive(:run).and_raise(Cocaine::ExitStatusError)
    subject.branch_exist?("branch").should be_false
  end
end

describe Kumade::Git, "#dirty?" do
  let(:environment) { "staging" }
  
  subject { Kumade::Git.new(false, environment) }

  it "should return true when dirty" do
    subject.should_receive(:run).with("git diff --exit-code").and_return(false)
    subject.dirty?.should be_true
  end
  
  it "should return false when not dirty" do
    subject.should_receive(:run).with("git diff --exit-code").and_return(true)
    subject.dirty?.should be_false
  end
end