require 'spec_helper'
require 'jammit'

module Kumade
  describe Deployer, "#pre_deploy" do
    before { subject.stub(:say) }

    it "calls the correct methods in order" do
      %w(
        ensure_clean_git
        ensure_rake_passes
        package_assets
        git_push
        ).each do |task|
        subject.should_receive(task).ordered.and_return(true)
      end

      subject.pre_deploy
    end

    it "pushes to origin" do
      %w(
        ensure_clean_git
        ensure_rake_passes
        package_assets
      ).each do |task|
        subject.stub(task)
      end

      subject.should_receive(:git_push).with('origin')
      subject.pre_deploy
    end
  end

  describe Deployer, "#deploy_to" do
    let(:remote_name){ 'staging' }
    let(:app_name){ 'kumade-staging' }

    before do
      subject.stub(:say)
      force_add_heroku_remote(remote_name, app_name)
    end

    after  { remove_remote(remote_name) }

    it "calls the correct methods in order" do
      subject.stub(:run => true)

      subject.should_receive(:ensure_heroku_remote_exists_for).
        ordered.
        with(remote_name)

      subject.should_receive(:pre_deploy).
        ordered.
        and_return(true)

      subject.should_receive(:git_force_push).
        ordered.
        and_return(true)

      subject.should_receive(:heroku_migrate).
        ordered.
        with(remote_name)

      subject.deploy_to(remote_name)
    end

    it "deploys to the correct remote" do
      subject.stub(:ensure_heroku_remote_exists_for => true,
                   :pre_deploy                      => true,
                   :on_cedar?                       => false,
                   :run                             => true)

      subject.should_receive(:git_force_push).with(remote_name)

      subject.deploy_to(remote_name)
    end
  end

  describe Deployer, "#git_push" do
    let(:remote){ 'origin' }

    before { subject.stub(:say) }

    it "calls `git push`" do
      subject.should_receive(:run).
        with("git push #{remote} master").
        and_return(true)
      subject.git_push(remote)
    end

    context "when `git push` fails" do
      before { subject.stub(:run => false) }

      it "prints an error message" do
        subject.should_receive(:error).with("Failed to push master -> #{remote}")

        subject.git_push(remote)
      end
    end

    context "when `git push` succeeds" do
      before { subject.stub(:run => true) }

      it "does not raise an error" do
        subject.should_not_receive(:error)
        subject.git_push(remote)
      end

      it "prints a success message" do
        subject.should_receive(:success).with("Pushed master -> #{remote}")

        subject.git_push(remote)
      end
    end
  end

  describe Deployer, "#git_force_push" do
    let(:remote){ 'origin' }
    before { subject.stub(:say) }

    it "calls `git push -f`" do
      subject.should_receive(:run).
        with("git push -f #{remote} master").
        and_return(true)
      subject.git_force_push(remote)
    end

    context "when `git push -f` fails" do
      before do
        subject.stub(:run => false)
      end

      it "prints an error" do
        subject.should_receive(:error).with("Failed to force push master -> #{remote}")
        subject.git_force_push(remote)
      end
    end

    context "when `git push -f` succeeds" do
      before do
        subject.stub(:run => true)
        subject.stub(:say)
      end

      it "does not raise an error" do
        subject.should_not_receive(:error)
        subject.git_force_push(remote)
      end

      it "prints a success message" do
        subject.should_receive(:success).
          with("Force pushed master -> #{remote}")

        subject.git_force_push(remote)
      end
    end
  end

  describe Deployer, "#ensure_clean_git" do
    before { subject.stub(:say) }

    context "when git is dirty" do
      before { subject.stub(:git_dirty? => true) }

      it "prints an error" do
        subject.should_receive(:error).with("Cannot deploy: repo is not clean.")
        subject.ensure_clean_git
      end
    end

    context "when git is clean" do
      before { subject.stub(:git_dirty? => false) }

      it "prints a success message" do
        subject.should_not_receive(:error)
        subject.should_receive(:success).with("Git repo is clean")

        subject.ensure_clean_git
      end
    end
  end

  describe Deployer, "#ensure_rake_passes" do
    context "with a default task" do
      before do
        subject.stub(:default_task_exists? => true)
      end

      it "prints a success message if the default task succeeds" do
        subject.stub(:rake_succeeded? => true)
        subject.should_not_receive(:error)
        subject.should_receive(:success).with("Rake passed")

        subject.ensure_rake_passes
      end

      it "prints an error if the default task failse" do
        subject.stub(:rake_succeeded? => false)
        subject.should_receive(:error).with("Cannot deploy: tests did not pass")

        subject.ensure_rake_passes
      end
    end
  end

  describe Deployer, "#default_task_exists?" do
    it "returns true because a default task does exist" do
      subject.default_task_exists?.should be_true
    end
  end

  describe Deployer, "#rake_succeeded?" do
    it "returns true if the default task passed" do
      subject.should_receive(:run).with("bundle exec rake").and_return(true)

      subject.rake_succeeded?.should be_true
    end

    it "returns false if the default task failed" do
      subject.should_receive(:run).with("bundle exec rake").and_raise("blerg")
      subject.rake_succeeded?.should be_false
    end
  end

  describe Deployer, "#package_assets" do
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

  describe Deployer, "#package_with_jammit" do
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
      before { subject.stub(:git_dirty? => true) }

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

    context "no assets were added" do
      before { subject.stub(:git_dirty? => false) }

      it "does not call git_add_and_commit_all_jammit_assets" do
        subject.should_not_receive(:git_add_and_commit_all_assets_in)

        subject.package_with_jammit
      end

      it "does not print a success message" do
        subject.should_not_receive(:success)
        subject.package_with_jammit
      end
    end
  end

  describe Deployer, "#package_with_more" do
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
        subject.stub(:git_dirty? => true)
        subject.should_receive(:success).with("Packaged assets with More")

        subject.package_with_more
      end

      it "calls git_add_and_commit_all_assets_in if assets were added" do
        subject.stub(:git_dirty?       => true,
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
        subject.stub(:git_dirty? => false)
        subject.should_not_receive(:say)

        subject.package_with_more
      end

      it "does not call git_add_and_commit_all_more_assets" do
        subject.stub(:run).with("bundle exec rake more:generate")
        subject.stub(:git_dirty? => false)
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

  describe Deployer, "#git_add_and_commit_all_assets_in" do
    before do
      subject.stub(:run => true)
      subject.stub(:say)
    end

    it "prints a success message" do
      subject.should_receive(:success).with("Added and committed all assets")

      subject.git_add_and_commit_all_assets_in('blerg')
    end

    it "runs the correct commands" do
      subject.should_receive(:run).
        with("git add blerg && git commit -m 'Assets'")

      subject.git_add_and_commit_all_assets_in('blerg')
    end

    it "prints an error if it could not add and commit assets" do
      subject.stub(:run => false)
      subject.should_receive(:error).with("Cannot deploy: couldn't commit assets")

      subject.git_add_and_commit_all_assets_in('blerg')
    end
  end

  describe Deployer, "#jammit_assets_path" do
    it "returns the correct asset path" do
      Jammit.stub(:package_path => 'blerg')
      current_dir = File.expand_path(Dir.pwd)
      subject.jammit_assets_path.should == File.join(current_dir, 'public', 'blerg')
    end
  end

  describe Deployer, "#more_assets_path" do
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

  describe Deployer, "#jammit_installed?" do
    it "returns true because it's loaded by the Gemfile" do
      Deployer.new.jammit_installed?.should be_true
    end

    it "returns false if jammit is not installed" do
      Deployer.new.jammit_installed?.should be_true
    end
  end

  describe Deployer, "#more_installed?" do
    before do
      if defined?(Less)
        Object.send(:remove_const, :Less)
      end
    end

    it "returns false if it does not find Less::More" do
      Deployer.new.more_installed?.should be_false
    end

    it "returns true if it finds Less::More" do
      module Less
        class More
        end
      end
      Deployer.new.more_installed?.should be_true
    end
  end

  describe Deployer, "#heroku_migrate" do
    let(:environment){ 'staging' }
    let(:app_name){ 'sushi' }

    before do
      subject.stub(:say)
      force_add_heroku_remote(environment, app_name)
    end

    after { remove_remote(environment) }

    it "runs db:migrate with the correct app" do
      subject.stub(:run => true)
      subject.should_receive(:heroku).
        with("rake db:migrate", app_name)
      subject.should_receive(:success).with("Migrated #{app_name}")

      subject.heroku_migrate(environment)
    end
  end

  describe Deployer, "#string_present?" do
    it "returns false for nil" do
      subject.string_present?(nil).should be_false
    end

    it "returns false for false" do
      subject.string_present?(false).should be_false
    end

    it "returns false for true" do
      subject.string_present?(true).should be_false
    end

    it "returns false for an empty string" do
      subject.string_present?('').should be_false
    end

    it "returns true for a non-empty string" do
      subject.string_present?('abc').should be_true
    end
  end

  describe Deployer, "#ensure_heroku_remote_exists_for" do
    let(:environment){ 'staging' }
    let(:bad_environment){ 'bad' }
    let(:staging_app_name) { 'staging-sushi' }

    before do
      subject.stub(:say)
      force_add_heroku_remote(environment, staging_app_name)
      `git remote add #{bad_environment} blerg@example.com`
    end

    after do
      remove_remote(environment)
      remove_remote(bad_environment)
    end

    context "when the remote points to Heroku" do
      it "does not print an error" do
        subject.should_not_receive(:error)

        subject.ensure_heroku_remote_exists_for(environment)
      end

      it "prints a success message" do
        subject.should_receive(:success).with("#{environment} is a Heroku remote")

        subject.ensure_heroku_remote_exists_for(environment)
      end
    end


    context "when the remote does not exist" do
      before { remove_remote(environment) }

      it "prints an error" do
        subject.should_receive(:error).with(%{Cannot deploy: "#{environment}" remote does not exist})

        subject.ensure_heroku_remote_exists_for(environment)
      end
    end

    context "when the remote does not point to Heroku" do
      it "prints an error" do
        subject.should_receive(:error).with(%{Cannot deploy: "#{bad_environment}" remote does not point to Heroku})

        subject.ensure_heroku_remote_exists_for(bad_environment)
      end
    end
  end

  describe Deployer, "#remote_exists?" do
    let(:remote_name){ 'staging' }

    before { force_add_heroku_remote(remote_name, 'i-am-a-heroku-app') }
    after  { remove_remote(remote_name) }

    it "returns true if the remote exists" do
      subject.remote_exists?(remote_name).should be_true
    end

    it "returns false if the remote does not exist" do
      remove_remote(remote_name)

      subject.remote_exists?(remote_name).should be_false
    end
  end

  describe Deployer, "#heroku" do
    let(:app_name){ 'sushi' }

    context "when on Cedar" do
      before { subject.stub(:on_cedar? => true) }
      it "runs commands with `run`" do
        subject.should_receive(:run_or_error).with("bundle exec heroku run rake --app #{app_name}", //)
        subject.heroku("rake", app_name)
      end
    end

    context "when not on Cedar" do
      before { subject.stub(:on_cedar? => false) }
      it "runs commands without `run`" do
        subject.should_receive(:run_or_error).with("bundle exec heroku rake --app #{app_name}", //)
        subject.heroku("rake", app_name)
      end
    end
  end

  describe Deployer, "#announce" do
    it "exists" do
      subject.should respond_to(:announce)
    end
  end

  describe Deployer, "#success" do
    it "exists" do
      subject.should respond_to(:success)
    end
  end

  describe Deployer, "#error" do
    it "exists" do
      subject.should respond_to(:error)
    end
  end
end
