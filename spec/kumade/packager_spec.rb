require 'spec_helper'

require 'jammit'

shared_context "with a fake Git" do
  let(:git) { stub() }
  subject   { Kumade::Packager.new(git) }
end

describe Kumade::Packager, "#run" do
  include_context "with a fake Git"

  before do
    subject.stubs(:package_with_jammit)
    subject.expects(:invoke_task).with("kumade:before_asset_compilation")
  end

  context "with Jammit installed" do
    it "calls package_with_jammit" do
      subject.run

      subject.should have_received(:package_with_jammit)
    end
  end

  context "with Jammit not installed" do
    before { subject.stubs(:jammit_installed? => false) }

    it "does not call package_with_jammit" do
      subject.run

      subject.should_not have_received(:package_with_jammit)
    end
  end

  context "with More installed" do
    before do
      subject.stubs(:jammit_installed? => false)
      subject.stubs(:more_installed? => true)
      subject.stubs(:package_with_more)
    end

    it "calls package_with_more" do
      subject.run

      subject.should have_received(:package_with_more)
    end
  end

  context "with More not installed" do
    before do
      subject.stubs(:jammit_installed? => false)
      subject.stubs(:more_installed? => false)
    end

    it "does not call package_with_more" do
      subject.run

      subject.should_not have_received(:package_with_more)
    end
  end
end

describe Kumade::Packager, "#package_with_jammit" do
  include_context "with a fake Git"

  before do
    subject.stubs(:git_add_and_commit_all_assets_in)
    subject.stubs(:success)
    subject.stubs(:error)
    Jammit.stubs(:package!)
  end

  it "calls Jammit.package!" do
    subject.package_with_jammit

    Jammit.should have_received(:package!).once
  end

  context "with updated assets" do
    before { subject.git.stubs(:dirty? => true) }

    it "prints the correct message" do
      subject.package_with_jammit

      subject.should have_received(:success).with("Packaged assets with Jammit")
    end

    it "calls git_add_and_commit_all_assets_in" do
      subject.stubs(:jammit_assets_path => 'jammit-assets')
      subject.expects(:git_add_and_commit_all_assets_in).
        with('jammit-assets').
        returns(true)

      subject.package_with_jammit
    end
  end

  it "prints an error if packaging failed" do
    Jammit.expects(:package!).raises(Jammit::MissingConfiguration.new("random Jammit error"))

    subject.package_with_jammit

    subject.should have_received(:error).with("Error: Jammit::MissingConfiguration: random Jammit error")
  end
end

describe Kumade::Packager, "#package_with_more" do
  include_context "with a fake Git"

  before do
    subject.stubs(:git_add_and_commit_all_assets_in => true,
                 :more_assets_path                 => 'assets')
    subject.stubs(:say)
  end

  it "calls the more:generate task" do
    git.expects(:dirty?).returns(true)
    subject.expects(:run).with("bundle exec rake more:generate")
    subject.package_with_more
  end

  context "with changed assets" do
    before do
      git.stubs(:dirty? => true)
    end

    it "prints a success message" do
      subject.stubs(:run).with("bundle exec rake more:generate")
      subject.expects(:success).with("Packaged assets with More")

      subject.package_with_more
    end

    it "calls git_add_and_commit_all_assets_in if assets were added" do
      subject.stubs(:more_assets_path => 'blerg')
      subject.stubs(:run).with("bundle exec rake more:generate")
      subject.expects(:git_add_and_commit_all_assets_in).
        with('blerg').
        returns(true)

      subject.package_with_more
    end
  end

  context "with no changed assets" do
    it "prints no message" do
      subject.stubs(:run).with("bundle exec rake more:generate")
      subject.stubs(:git => mock(:dirty? => false))
      subject.expects(:say).never

      subject.package_with_more
    end

    it "does not call git_add_and_commit_all_more_assets" do
      subject.stubs(:run).with("bundle exec rake more:generate")
      subject.stubs(:git => mock(:dirty? => false))
      subject.expects(:git_add_and_commit_all_assets_in).never

      subject.package_with_more
    end
  end

  it "prints an error if packaging failed" do
    subject.stubs(:run).with("bundle exec rake more:generate").raises("blerg")

    subject.expects(:error).with("Error: RuntimeError: blerg")

    subject.package_with_more
  end
end

describe Kumade::Packager, "#git_add_and_commit_all_assets_in" do
  include_context "with a fake Git"

  it "should call git.add_and_commit_all_in" do
    git.expects(:add_and_commit_all_in).with("dir", 'deploy', 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    subject.git_add_and_commit_all_assets_in("dir")
  end
end

describe Kumade::Packager, "#jammit_assets_path" do
  let(:git)      { stub() }
  let(:packager) { Kumade::Packager.new(git) }

  before do
    Jammit.stubs(:package_path).returns('blerg')
  end

  subject { packager.jammit_assets_path }

  it { should == File.join(Jammit::PUBLIC_ROOT, 'blerg') }
end

describe Kumade::Packager, "#more_assets_path" do
  include_context "with a fake Git"

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
  include_context "with a fake Git"

  it "returns true because it's loaded by the Gemfile" do
    subject.jammit_installed?.should be_true
  end

  it "returns false if jammit is not installed" do
    subject.jammit_installed?.should be_true
  end
end

describe Kumade::Packager, "#more_installed?" do
  include_context "with a fake Git"

  context "when More is not installed" do
    before do
      if defined?(Less)
        Object.send(:remove_const, :Less)
      end
    end

    it "returns false" do
      subject.more_installed?.should be_false
    end
  end

  context "when More is installed" do
    before do
      module Less
        class More
        end
      end
    end

    it "returns true" do
      subject.more_installed?.should be_true
    end
  end
end
