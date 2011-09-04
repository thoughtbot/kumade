require 'spec_helper'

describe Kumade::Packager, "#run" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  context "with Jammit installed" do
    it "calls package_with_jammit" do
      subject.should_receive(:package_with_jammit)
      subject.run
    end
  end

  context "with Jammit not installed" do
    before { subject.stub(:jammit_installed? => false) }
    it "does not call package_with_jammit" do
      subject.should_not_receive(:package_with_jammit)
      subject.run
    end
  end

  context "with More installed" do
    before do
      subject.stub(:jammit_installed? => false)
      subject.stub(:more_installed? => true)
    end

    it "calls package_with_more" do
      subject.should_receive(:package_with_more)
      subject.run
    end
  end

  context "with More not installed" do
    before do
      subject.stub(:jammit_installed? => false)
      subject.stub(:more_installed? => false)
    end

    it "does not call package_with_more" do
      subject.should_not_receive(:package_with_more)
      subject.run
    end
  end

  context "with custom rake task installed" do
    before do
      subject.stub(:jammit_installed?  => false,
                   :more_installed?    => false,
                   :invoke_custom_task => nil,
                   :custom_task?       => true)
    end

    it "invokes custom task" do
      subject.should_receive(:invoke_custom_task)
      subject.run
    end
  end

  context "with custom rake task not installed" do
    before do
      subject.stub(:jammit_installed?  => false,
                   :more_installed?    => false,
                   :invoke_custom_task => nil,
                   :custom_task?       => false)
    end

    it "does not invoke custom task" do
      subject.should_not_receive(:invoke_custom_task)
      subject.run
    end
  end
end

describe Kumade::Packager, "#invoke_custom_task" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  before do
    subject.stub(:say)
    Rake::Task.stub(:[] => task)
  end

  let(:task) { stub('task', :invoke => nil) }

  it "calls deploy task" do
    Rake::Task.should_receive(:[]).with("kumade:before_asset_compilation")
    task.should_receive(:invoke)
    subject.invoke_custom_task
  end
end

describe Kumade::Packager, "#custom_task?" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  before do
    Rake::Task.clear
  end

  it "returns true if it task found" do
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

describe Kumade::Packager, "#package_with_jammit" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
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

describe Kumade::Packager, "#package_with_more" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  before do
    subject.stub(:git_add_and_commit_all_assets_in => true,
                 :more_assets_path                 => 'assets')
    subject.stub(:say)
  end

  it "calls the more:generate task" do
    git_mock.should_receive(:git_dirty?).and_return(true)
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

describe Kumade::Packager, "#git_add_and_commit_all_assets_in" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  let(:git_mock) { mock() }
  before { subject.stub(:git => git_mock) }
  
  it "should call git.add_and_commit_all_in" do
    git_mock.should_receive(:add_and_commit_all_in).with("dir", 'deploy', 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    subject.git_add_and_commit_all_assets_in("dir")
  end
end

describe Kumade::Packager, "#jammit_assets_path" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  it "returns the correct asset path" do
    Jammit.stub(:package_path => 'blerg')
    current_dir = File.expand_path(Dir.pwd)
    subject.jammit_assets_path.should == File.join(current_dir, 'public', 'blerg')
  end
end

describe Kumade::Packager, "#more_assets_path" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
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

describe Kumade::Packager, "#jammit_installed?" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
  it "returns true because it's loaded by the Gemfile" do
    subject.jammit_installed?.should be_true
  end

  it "returns false if jammit is not installed" do
    subject.jammit_installed?.should be_true
  end
end

describe Kumade::Packager, "#more_installed?" do
  let(:git_mock) { mock() }
  subject { Kumade::Packager.new(false, 'staging', git_mock) }
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