require 'spec_helper'
require 'jammit'

class Kumade
  describe Deployer, "#load_tasks" do
    it "loads the deploy tasks" do
      Rake.application.tasks.should be_empty
      subject.load_tasks
      task_names = Rake.application.tasks.map{|task| task.name }
      %w(deploy deploy:production deploy:staging).each do |expected_name|
        task_names.should include expected_name
      end
    end
  end

  describe Deployer, "#pre_deploy" do
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
  end

  describe Deployer, "#deploy_to_staging" do
    it "calls the correct methods in order" do
      subject.stub(:run => true)

      subject.should_receive(:pre_deploy).
        ordered.
        and_return(true)

      subject.should_receive(:git_force_push).
        ordered.
        with('staging').
        and_return(true)

      subject.should_receive(:heroku_migrate).
        ordered.
        with(:staging)

      subject.deploy_to_staging
    end

    it "deploys to Kumade.staging" do
      subject.stub(:pre_deploy => true,
                   :run        => true)
      Kumade.staging = 'orange'

      subject.should_receive(:git_force_push).with('orange')

      subject.deploy_to_staging
    end
  end

  describe Deployer, "#deploy_to_production" do
    it "calls the correct methods in order" do
      subject.stub(:run => true)

      subject.should_receive(:pre_deploy).
        ordered.
        and_return(true)

      subject.should_receive(:git_force_push).
        ordered.
        with('production').
        and_return(true)

      subject.should_receive(:heroku_migrate).
        ordered.
        with(:production)

      subject.deploy_to_production
    end

    it "deploys to Kumade.production" do
      subject.stub(:pre_deploy => true,
                   :run        => true)
      Kumade.production = 'orange'

      subject.should_receive(:git_force_push).with('orange')

      subject.deploy_to_production
    end
  end

  describe Deployer, "#git_push" do
    let(:remote){ 'origin' }

    before { subject.stub(:announce) }

    it "calls `git push`" do
      subject.should_receive(:run).
        with("git push #{remote} master").
        and_return(true)
      subject.git_push(remote)
    end

    context "when `git push` fails" do
      before do
        subject.stub(:run => false)
      end

      it "raises an error" do
        lambda do
          subject.git_push(remote)
        end.should raise_error("Failed to push master -> #{remote}")
      end
    end

    context "when `git push` succeeds" do
      before do
        subject.stub(:run => true)
      end

      it "does not raise an error" do
        subject.stub(:announce => false)
        lambda do
          subject.git_push(remote)
        end.should_not raise_error
      end

      it "prints the correct message" do
        subject.should_receive(:announce).
          with("Pushed master -> #{remote}")

        subject.git_push(remote)
      end
    end
  end

  describe Deployer, "#git_force_push" do
    let(:remote){ 'origin' }
    before { subject.stub(:announce) }

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

      it "raises an error" do
        lambda do
          subject.git_force_push(remote)
        end.should raise_error("Failed to force push master -> #{remote}")
      end
    end

    context "when `git push -f` succeeds" do
      before do
        subject.stub(:run => true)
      end

      it "does not raise an error" do
        lambda do
          subject.git_force_push(remote)
        end.should_not raise_error
      end

      it "prints the correct message" do
        subject.should_receive(:announce).
          with("Force pushed master -> #{remote}")

        subject.git_force_push(remote)
      end
    end
  end

  describe Deployer, "#ensure_clean_git" do
    context "when git is dirty" do
      before { subject.stub(:git_dirty? => true) }

      it "raises an error" do
        lambda do
          subject.ensure_clean_git
        end.should raise_error("Cannot deploy: repo is not clean.")
      end
    end

    context "when git is clean" do
      before { subject.stub(:git_dirty? => false) }

      it "does not raise an error" do
        lambda do
          subject.ensure_clean_git
        end.should_not raise_error
      end
    end
  end

  describe Deployer, "#ensure_rake_passes" do
    context "with a default task" do
      before do
        subject.stub(:default_task_exists? => true)
      end

      it "does not raise an error if the default task succeeds" do
        subject.stub(:rake_succeeded? => true)
        lambda do
          subject.ensure_rake_passes
        end.should_not raise_error
      end

      it "raises an error if the default task failse" do
        subject.stub(:rake_succeeded? => false)
        lambda do
          subject.ensure_rake_passes
        end.should raise_error("Cannot deploy: tests did not pass")
      end
    end
  end

  describe Deployer, "#default_task_exists?" do
    before { Rake::Task.clear }

    it "returns true if a default task does exist" do
      Rake::Task.define_task(:default){}

      subject.default_task_exists?.should be_true
    end

    it "returns false if a default task does not exist" do
      subject.default_task_exists?.should be_false
    end
  end

  describe Deployer, "#rake_succeeded?" do
    before { Rake::Task.clear }

    it "returns true if the default task passed" do
      Rake::Task.define_task(:default){}

      subject.rake_succeeded?.should be_true
    end

    it "returns false if the default task failed" do
      Rake::Task.define_task(:default){ fail "blerg" }
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
        subject.should_receive(:package_with_jammit).exactly(0).times
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
        subject.should_receive(:package_with_more).exactly(0).times
        subject.package_assets
      end
    end
  end

  describe Deployer, "#package_with_jammit" do
    before do
      subject.stub(:git_add_and_commit_all_assets_in)
      subject.stub(:announce)
      Jammit.stub(:package!)
    end

    it "calls Jammit.package!" do
      Jammit.should_receive(:package!).once
      subject.package_with_jammit
    end

    it "prints the correct message if packaging succeeded" do
      subject.should_receive(:announce).with("Successfully packaged with Jammit")

      subject.package_with_jammit
    end

    it "raises an error if packaging failed" do
      Jammit.stub(:package!) do
        raise Jammit::MissingConfiguration.new("random Jammit error")
      end

      lambda do
        subject.package_with_jammit
      end.should raise_error(Jammit::MissingConfiguration)
    end

    it "calls git_add_and_commit_all_assets_in if assets were added" do
      subject.stub(:git_dirty? => true,
                   :absolute_assets_path => 'blerg')
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('blerg').
        and_return(true)

      subject.package_with_jammit
    end

    it "does not call git_add_and_commit_all_jammit_assets if no assets were added" do
      subject.stub(:git_dirty? => false)
      subject.should_receive(:git_add_and_commit_all_assets_in).exactly(0).times

      subject.package_with_jammit
    end
  end

  describe Deployer, "#package_with_more" do
    before do
      subject.stub(:git_add_and_commit_all_assets_in => true,
                   :more_assets_path => 'assets',
                   :announce         => nil)
      Rake::Task.clear
      Rake::Task.define_task('more:generate'){}
    end

    it "calls the more:generate task" do
      Rake::Task.clear
      more_generate_task = Rake::Task.define_task('more:generate'){}
      more_generate_task.should_receive(:invoke).once
      subject.package_with_more
    end

    it "prints the correct message if packaging succeeded" do
      subject.stub(:git_dirty? => true)
      subject.should_receive(:announce).with("Successfully packaged with More")

      subject.package_with_more
    end

    it "prints no message if packaging was a no-op" do
      subject.stub(:git_dirty? => false)
      subject.should_receive(:announce).exactly(0).times

      subject.package_with_more
    end

    it "raises an error if packaging failed" do
      Rake::Task.clear
      Rake::Task.define_task('more:generate') do
        fail "blerg"
      end

      lambda do
        subject.package_with_more
      end.should raise_error("blerg")
    end

    it "calls git_add_and_commit_all_assets_in if assets were added" do
      subject.stub(:git_dirty?       => true,
                   :more_assets_path => 'blerg')
      subject.should_receive(:git_add_and_commit_all_assets_in).
        with('blerg').
        and_return(true)

      subject.package_with_more
    end

    it "does not call git_add_and_commit_all_more_assets if no assets were added" do
      subject.stub(:git_dirty? => false)
      subject.should_receive(:git_add_and_commit_all_assets_in).exactly(0).times

      subject.package_with_more
    end
  end

  describe Deployer, "#git_add_and_commit_all_assets_in" do
    before do
      subject.stub(:run     => true,
                  :announce => nil)
    end

    it "announces the correct message" do
      subject.should_receive(:announce).with("Committing assets")

      subject.git_add_and_commit_all_assets_in('blerg')
    end

    it "runs the correct commands" do
      subject.should_receive(:run).
        with("git add blerg && git commit -m 'Assets'")

      subject.git_add_and_commit_all_assets_in('blerg')
    end

    it "raises an error if it could not add and commit assets" do
      subject.stub(:run => false)

      lambda do
        subject.git_add_and_commit_all_assets_in('blerg')
      end.should raise_error("Cannot deploy: couldn't commit assets")
    end
  end

  describe Deployer, "#absolute_assets_path" do
    it "returns the correct asset path" do
      Jammit.stub(:package_path => 'blerg')
      current_dir = File.expand_path(Dir.pwd)
      subject.absolute_assets_path.should == File.join(current_dir, 'public', 'blerg')
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
      subject.jammit_installed?.should be_true
    end
  end

  describe Deployer, "#more_installed?" do
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

  describe Deployer, "#heroku_migrate" do
    let(:staging_app)   { 'staging-sushi' }
    let(:production_app){ 'production-sushi' }

    before do
      Kumade.reset!
      Kumade.staging_app    = staging_app
      Kumade.production_app = production_app
    end

    it "runs db:migrate with the correct staging app" do
      subject.should_receive(:run).
        with("bundle exec heroku rake db:migrate --app #{staging_app}")

      subject.heroku_migrate(:staging)
    end

    it "runs db:migrate with the correct production app" do
      subject.should_receive(:run).
        with("bundle exec heroku rake db:migrate --app #{production_app}")

      subject.heroku_migrate(:production)
    end
  end
end
