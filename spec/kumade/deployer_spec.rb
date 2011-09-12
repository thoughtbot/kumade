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


describe Kumade::Deployer, "#ensure_clean_git" do
  it "calls git.ensure_clean_git" do
    subject.git.should_receive(:ensure_clean_git)
    subject.ensure_clean_git
  end
end

describe Kumade::Deployer, "#package_assets" do
  context "with Jammit installed" do
    it "calls package_with_jammit" do
      subject.should_receive(:package_with_jammit)
      subject.package_assets
    end
  end

  context "with Jammit not installed" do
    before { subject.stub(:jammit_installed? => false) }

    it "does not call package_with_jammit" do
      subject.should_not_receive(:package_with_jammit)
      subject.package_assets
    end
  end

  context "with More installed" do
    before do
      subject.stub(:jammit_installed? => false)
      subject.stub(:more_installed? => true)
    end

    it "calls package_with_more" do
      subject.should_receive(:package_with_more)
      subject.package_assets
    end
  end

  context "with More not installed" do
    before do
      subject.stub(:jammit_installed? => false)
      subject.stub(:more_installed? => false)
    end

    it "does not call package_with_more" do
      subject.should_not_receive(:package_with_more)
      subject.package_assets
    end
  end

  context "with custom rake task installed" do
    before do
      Rake::Task.stub(:task_defined?).
        with("kumade:before_asset_compilation").
        and_return(true)

      subject.stub(:jammit_installed?  => false,
                   :more_installed?    => false)
    end

    it "invokes the custom task" do
      subject.should_receive(:invoke_custom_task)
      subject.package_assets
    end
  end

  context "with custom rake task not installed" do
    before do
      Rake::Task.stub(:task_defined?).
        with("kumade:before_asset_compilation").
        and_return(false)

      subject.stub(:jammit_installed?  => false,
                   :more_installed?    => false)
    end

    it "does not invoke custom task" do
      subject.should_not_receive(:invoke_custom_task)
      subject.package_assets
    end
  end
end

describe Kumade::Deployer, "#package_with_jammit" do
  before do
    subject.stub(:git_add_and_commit_all_assets_in)
    Jammit.stub(:package!)
  end

  it "calls Jammit.package!" do
    Jammit.should_receive(:package!)
    subject.package_with_jammit
  end

  context "with updated assets" do
    before { subject.git.stub(:dirty?).and_return(true) }

    it "prints the correct message" do
      STDOUT.should_receive(:puts).with(/Packaged assets with Jammit/)

      subject.package_with_jammit
    end

    it "calls git_add_and_commit_all_assets_in" do
      subject.stub(:jammit_assets_path).and_return('jammit-assets')
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('jammit-assets')

      subject.package_with_jammit
    end
  end

  it "prints an error if packaging failed" do
    Jammit.stub(:package!).and_raise(Jammit::MissingConfiguration.new("random Jammit error"))
    subject.should_receive(:error).with("Error: Jammit::MissingConfiguration: random Jammit error")

    subject.package_with_jammit
  end
end

describe Kumade::Deployer, "#invoke_custom_task" do
  let(:task) { stub('task', :invoke => nil) }

  before do
    subject.stub(:say)
    Rake::Task.stub(:[] => task)
  end

  it "calls deploy task" do
    Rake::Task.should_receive(:[]).with("kumade:before_asset_compilation")
    task.should_receive(:invoke)
    subject.invoke_custom_task
  end
end

describe Kumade::Deployer, "#package_with_more" do
  before do
    subject.stub(:git_add_and_commit_all_assets_in => true,
                 :more_assets_path                 => 'assets')
    subject.stub(:say)
  end

  it "calls the more:generate task" do
    subject.should_receive(:run).with("bundle exec rake more:generate")
    subject.package_with_more
  end

  context "with changed assets" do
    it "prints a success message" do
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.stub(:git => mock(:dirty? => true))
      subject.should_receive(:success).with("Packaged assets with More")

      subject.package_with_more
    end

    it "calls git_add_and_commit_all_assets_in if assets were added" do
      subject.stub(:git => mock(:dirty? => true),
                   :more_assets_path => 'blerg')
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('blerg').
        and_return(true)

      subject.package_with_more
    end
  end

  context "with no changed assets" do
    before { subject.stub(:git => stub(:dirty? => false)) }

    it "prints no message" do
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.should_not_receive(:say)

      subject.package_with_more
    end

    it "does not call git_add_and_commit_all_assets_in" do
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.should_not_receive(:git_add_and_commit_all_assets_in)

      subject.package_with_more
    end
  end

  it "prints an error if packaging failed" do
    subject.should_receive(:run).with("bundle exec rake more:generate").and_raise(RuntimeError.new("blerg"))

    subject.should_receive(:error).with("Error: RuntimeError: blerg")

    subject.package_with_more
  end
end

describe Kumade::Deployer, "#git_add_and_commit_all_assets_in" do
  let(:git_mock) { mock() }

  before { subject.stub(:git => git_mock) }

  it "calls git.add_and_commit_all_in" do
    git_mock.should_receive(:add_and_commit_all_in).with("dir", 'deploy', 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    subject.git_add_and_commit_all_assets_in("dir")
  end
end

describe Kumade::Deployer, "#jammit_assets_path" do
  before do
    Jammit.stub(:package_path).and_return('blerg')
  end

  its(:jammit_assets_path) { should == File.join(Jammit::PUBLIC_ROOT, 'blerg') }
end

describe Kumade::Deployer, "#more_assets_path" do
  before do
    module ::Less
      class More
        def self.destination_path
          'blerg'
        end
      end
    end
  end

  its(:more_assets_path) { should == 'public/blerg' }
end

describe Kumade::Deployer, "#jammit_installed?" do
  it "returns true because it's loaded by the Gemfile" do
    subject.jammit_installed?.should be_true
  end
end

describe Kumade::Deployer, "#more_installed?" do
  before do
    if defined?(Less)
      Object.send(:remove_const, :Less)
    end
  end

  it "returns false if it does not find Less::More" do
    subject.more_installed?.should be_false
  end

  it "returns true if it finds Less::More" do
    module Less
      class More
      end
    end

    subject.more_installed?.should be_true
  end
end

describe Kumade::Deployer, "#custom_task?" do
  before do
    Rake::Task.clear
  end

  it "returns true if the task exists" do
    namespace :kumade do
      task :before_asset_compilation do
      end
    end

    subject.custom_task?.should be_true
  end

  it "returns false if task not found" do
    subject.custom_task?.should be_false
  end
end

describe Kumade::Deployer, "#post_deploy" do
  it "deletes the deploy branch" do
    Kumade::Git.any_instance.should_receive(:delete).with('deploy', 'master')

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

