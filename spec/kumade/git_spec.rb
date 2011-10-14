require 'spec_helper'

describe Kumade::Git, "#heroku_remote?", :with_mock_outputter do
  context "when the environment is a Heroku repository" do
    include_context "with Heroku environment"

    it { should be_heroku_remote }
  end

  context "when the environment is a Heroku repository managed with heroku-accounts" do
    include_context "with Heroku-accounts environment"

    it { should be_heroku_remote }
  end

  context "when the environment is not a Heroku repository" do
    include_context "with non-Heroku environment"

    it { should_not be_heroku_remote }
  end
end

describe Kumade::Git, ".environments", :with_mock_outputter do
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

describe Kumade::Git, "#push", :with_mock_outputter do
  let(:branch)       { 'branch' }
  let(:remote)       { 'my-remote' }
  let(:command_line) { stub("Kumade::CommandLine instance", :run_or_error => true) }

  before do
    Kumade::CommandLine.stubs(:new => command_line)
  end

  it "pushes to the correct remote" do
    subject.push(branch, remote)
    Kumade::CommandLine.should have_received(:new).with("git push #{remote} #{branch}")
    command_line.should have_received(:run_or_error).once
  end

  it "can force push" do
    subject.push(branch, remote, true)
    Kumade::CommandLine.should have_received(:new).with("git push -f #{remote} #{branch}")
    command_line.should have_received(:run_or_error).once
  end

  it "prints a success message" do
    subject.push(branch, remote)
    Kumade.configuration.outputter.should have_received(:success).with("Pushed #{branch} -> #{remote}")
  end
end

describe Kumade::Git, "#create", :with_mock_outputter do
  let(:branch) { "my-new-branch" }
  it "creates a branch" do
    subject.create(branch)
    system("git show-ref #{branch} > /dev/null").should be_true
  end

  context "when the branch already exists" do
    before do
      subject.create(branch)
    end

    it "does not error" do
      subject.create(branch)
      Kumade.configuration.outputter.should have_received(:error).never
    end
  end
end

describe Kumade::Git, "#delete", :with_mock_outputter do
  let(:branch_to_delete)   { 'branch_to_delete' }
  let(:branch_to_checkout) { 'branch_to_checkout' }

  before do
    subject.create(branch_to_delete)
    subject.create(branch_to_checkout)
  end

  it "switches to a branch" do
    subject.delete(branch_to_delete, branch_to_checkout)
    subject.current_branch.should == branch_to_checkout
  end

  it "deletes a branch" do
    subject.delete(branch_to_delete, branch_to_checkout)
    `git show-ref #{branch_to_delete}`.strip.should be_empty
  end
end

describe Kumade::Git, "#add_and_commit_all_assets_in", :with_mock_outputter do
  let(:directory) { 'assets' }

  before do
    Dir.mkdir(directory)
    Dir.chdir(directory) do
      File.open('new-file', 'w') do |f|
        f.write('some content')
      end
    end
  end

  it "switches to the deploy branch" do
    subject.add_and_commit_all_assets_in(directory)
    subject.current_branch.should == Kumade::Heroku::DEPLOY_BRANCH
  end

  it "uses a bland commit message" do
    subject.add_and_commit_all_assets_in(directory)
    `git log -n1 --pretty=format:%s`.should == 'Compiled assets.'
  end

  it "commits everything in the dir" do
    subject.add_and_commit_all_assets_in(directory)
    subject.should_not be_dirty
  end

  it "prints a success message" do
    subject.add_and_commit_all_assets_in(directory)
    Kumade.configuration.outputter.should have_received(:success).with('Added and committed all assets')
  end

  context "if the command fails" do
    let(:command_line) { mock('CommandLine', :run_or_error => nil) }
    before do
      Kumade::CommandLine.stubs(:new => command_line)
    end

    it "prints an error message if something goes wrong" do
      subject.add_and_commit_all_assets_in(directory)
      command_line.should have_received(:run_or_error).once
    end
  end
end

describe Kumade::Git, "#current_branch", :with_mock_outputter do
  it "returns the current branch" do
    subject.current_branch.should == 'master'
    `git checkout -b new-branch 2>/dev/null`
    subject.current_branch.should == 'new-branch'
  end
end

describe Kumade::Git, "#remote_exists?", :with_mock_outputter do
  context "when pretending" do
    before { Kumade.configuration.pretending = true }
    it "returns true no matter what" do
      subject.remote_exists?('not-a-remote').should be_true
    end
  end

  context "when not pretending" do
    let(:good_remote) { 'good-remote' }
    let(:bad_remote)  { 'bad-remote' }
    before do
      Kumade.configuration.pretending = false
      force_add_heroku_remote(good_remote)
    end

    it "returns true if the remote exists" do
      subject.remote_exists?(good_remote).should be_true
    end

    it "returns false if the remote does not exist" do
      subject.remote_exists?(bad_remote).should be_false
    end
  end
end

describe Kumade::Git, "#dirty?", :with_mock_outputter do
  context "when dirty" do
    before { dirty_the_repo }

    it { should be_dirty }
  end

  context "when clean" do
    it { should_not be_dirty }
  end
end


describe Kumade::Git, "#ensure_clean_git", :with_mock_outputter do
  context "when pretending" do
    before do
      Kumade.configuration.pretending = true
      dirty_the_repo
    end

    it "prints a success message" do
      subject.ensure_clean_git
      Kumade.configuration.outputter.should have_received(:success).with("Git repo is clean")
    end
  end

  context "when repo is clean" do
    it "prints a success message" do
      subject.ensure_clean_git
      Kumade.configuration.outputter.should have_received(:success).with("Git repo is clean")
    end
  end

  context "when repo is dirty" do
    before { dirty_the_repo }

    it "prints an error message" do
      subject.ensure_clean_git
      Kumade.configuration.outputter.should have_received(:error).with("Cannot deploy: repo is not clean.")
    end
  end
end
