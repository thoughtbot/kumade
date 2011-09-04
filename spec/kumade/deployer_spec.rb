require 'spec_helper'

describe Kumade::Deployer, "#pre_deploy" do

  context "running tests first" do
    subject { Kumade::Deployer.new(:tests => true) }
    it "calls the correct methods in order" do
      %w(
        ensure_clean_git
        run_tests
        package_assets
        sync_github
        ).each do |task|
        subject.should_receive(task).ordered.and_return(true)
      end

      subject.pre_deploy
    end
  end

  context "without running tests first" do
  end

  it "syncs to github" do
    %w(
      ensure_clean_git
      run_tests
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

describe Kumade::Deployer, "#run_tests" do
  before { subject.stub(:say) }
  it "should call spec, cucumber, test and features tasks" do
    subject.should_receive(:invoke_task).with("spec")
    subject.should_receive(:invoke_task).with("cucumber")
    subject.should_receive(:invoke_task).with("test")
    subject.should_receive(:invoke_task).with("features")
    subject.run_tests
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

describe Kumade::Deployer, "#sync_heroku" do
  let(:environment) { 'my-env' }
  subject { Kumade::Deployer.new(:environment => environment) }
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

describe Kumade::Deployer, "#package_assets" do
  it "should call 'kumade:before_asset_compilation'" do
    subject.stub(:jammit_installed?  => false,
                 :more_installed?    => false)
    subject.should_receive(:invoke_task).with("kumade:before_asset_compilation")
    subject.package_assets
  end
  
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
end

describe Kumade::Deployer, "#package_with_jammit" do
  before do
    subject.stub(:git_add_and_commit_all_assets_in)
    subject.stub(:say)
    Jammit.stub(:package!)
  end

  it "calls Jammit.package!" do
    Jammit.should_receive(:package!).once
    subject.package_with_jammit
  end

  context "with updated assets" do
    before { subject.stub(:git => mock(:git_dirty? => true)) }

    it "prints the correct message" do
      subject.should_receive(:success).with("Packaged assets with Jammit")

      subject.package_with_jammit
    end

    it "calls git_add_and_commit_all_assets_in" do
      subject.stub(:jammit_assets_path => 'jammit-assets')
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('jammit-assets').
        and_return(true)

      subject.package_with_jammit
    end
  end

  it "prints an error if packaging failed" do
    Jammit.stub(:package!) do
      raise Jammit::MissingConfiguration.new("random Jammit error")
    end
    subject.should_receive(:error).with("Error: Jammit::MissingConfiguration: random Jammit error")

    subject.package_with_jammit
  end
end

describe Kumade::Deployer, "#invoke_task" do
  before do
    subject.stub(:say)
    Rake::Task.stub(:[] => task)
  end

  let(:task) { stub('task', :invoke => nil) }
  
  context "with task" do
    it "calls given task" do
      subject.should_receive(:task_exist?).with("kumade:before_asset_compilation").and_return(true)
      Rake::Task.should_receive(:[]).with("kumade:before_asset_compilation")
      task.should_receive(:invoke)
      subject.invoke_task("kumade:before_asset_compilation")
    end
  end
  context "without task" do
    it "calls given task" do
      Rake::Task.should_not_receive(:[]).with("kumade:before_asset_compilation")
      task.should_not_receive(:invoke)
      subject.invoke_task("kumade:before_asset_compilation")
    end
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
      subject.stub(:git => mock(:git_dirty? => true))
      subject.should_receive(:success).with("Packaged assets with More")

      subject.package_with_more
    end

    it "calls git_add_and_commit_all_assets_in if assets were added" do
      subject.stub(:git => mock(:git_dirty? => true),
                   :more_assets_path => 'blerg')
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('blerg').
        and_return(true)

      subject.package_with_more
    end
  end

  context "with no changed assets" do
    it "prints no message" do
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.stub(:git => mock(:git_dirty? => false))
      subject.should_not_receive(:say)

      subject.package_with_more
    end

    it "does not call git_add_and_commit_all_more_assets" do
      subject.stub(:run).with("bundle exec rake more:generate")
      subject.stub(:git => mock(:git_dirty? => false))
      subject.should_not_receive(:git_add_and_commit_all_assets_in)

      subject.package_with_more
    end
  end

  it "prints an error if packaging failed" do
    subject.stub(:run) do |arg|
      if arg == "bundle exec rake more:generate"
        raise "blerg"
      end
    end

    subject.should_receive(:error).with("Error: RuntimeError: blerg")

    subject.package_with_more
  end
end

describe Kumade::Deployer, "#git_add_and_commit_all_assets_in" do
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  
  it "should call git.add_and_commit_all_in" do
    git_mock.should_receive(:add_and_commit_all_in).with("dir", 'deploy', 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    subject.git_add_and_commit_all_assets_in("dir")
  end
end

describe Kumade::Deployer, "#jammit_assets_path" do
  it "returns the correct asset path" do
    Jammit.stub(:package_path => 'blerg')
    current_dir = File.expand_path(Dir.pwd)
    subject.jammit_assets_path.should == File.join(current_dir, 'public', 'blerg')
  end
end

describe Kumade::Deployer, "#more_assets_path" do
  it "returns the correct asset path" do
    module ::Less
      class More
        def self.destination_path
          'blerg'
        end
      end
    end
    subject.more_assets_path.should == 'public/blerg'
  end
end

describe Kumade::Deployer, "#jammit_installed?" do
  it "returns true because it's loaded by the Gemfile" do
    Kumade::Deployer.new.jammit_installed?.should be_true
  end

  it "returns false if jammit is not installed" do
    Kumade::Deployer.new.jammit_installed?.should be_true
  end
end

describe Kumade::Deployer, "#more_installed?" do
  before do
    if defined?(Less)
      Object.send(:remove_const, :Less)
    end
  end

  it "returns false if it does not find Less::More" do
    Kumade::Deployer.new.more_installed?.should be_false
  end

  it "returns true if it finds Less::More" do
    module Less
      class More
      end
    end
    Kumade::Deployer.new.more_installed?.should be_true
  end
end

describe Kumade::Deployer, "#task_exist?" do
  before do
    Rake::Task.clear
  end

  it "returns true if it task found" do
    namespace :kumade do
      task :before_asset_compilation do

      end
    end
    Kumade::Deployer.new.task_exist?("kumade:before_asset_compilation").should be_true
  end

  it "returns false if task not found" do
    Kumade::Deployer.new.task_exist?("kumade:before_asset_compilation").should be_false
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
  let(:git_mock) { mock() }

  before do
    subject.stub(:git).and_return(git_mock)
    subject.stub(:say)
  end

  context "when the remote points to Heroku" do
    before do
      git_mock.should_receive(:remote_exists?).with(environment).and_return(true)
      git_mock.should_receive(:heroku_remote?).and_return(true)
    end
    subject { Kumade::Deployer.new(:environment => environment) } 

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
    before do
      git_mock.should_receive(:remote_exists?).with(environment).and_return(false)
    end
    subject { Kumade::Deployer.new(:environment => environment) }

    it "prints an error" do
      subject.should_receive(:error).with(%{Cannot deploy: "#{environment}" remote does not exist})
      subject.ensure_heroku_remote_exists
    end
  end

  context "when the remote does not point to Heroku" do
    before do
      git_mock.should_receive(:remote_exists?).with(bad_environment).and_return(true)
      git_mock.should_receive(:heroku_remote?).and_return(false)
    end
    subject { Kumade::Deployer.new(:environment => bad_environment) }

    it "prints an error" do
      subject.should_receive(:error).with(%{Cannot deploy: "#{bad_environment}" remote does not point to Heroku})
      subject.ensure_heroku_remote_exists
    end
  end
end

describe Kumade::Deployer, "#heroku" do
  context "when on Cedar" do
    subject { Kumade::Deployer.new(:cedar => true) }

    it "runs commands with `run`" do
      subject.should_receive(:run_or_error).with("bundle exec heroku run rake --remote staging", //)
      subject.heroku("rake")
    end
  end

  context "when not on Cedar" do
    subject { Kumade::Deployer.new(:cedar => false) }

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
