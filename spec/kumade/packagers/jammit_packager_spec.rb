require "spec_helper"

require "jammit"

describe Kumade::JammitPackager, :with_mock_outputter do
  subject { Kumade::JammitPackager }

  it_should_behave_like "packager"

  it "has the correct asset path" do
    subject.assets_path.should == File.join(jammit_public_root, Jammit.package_path)
  end

  it "knows how to package itself" do
    ::Jammit.stubs(:package!)
    subject.package
    ::Jammit.should have_received(:package!).once
  end

  context "when Jammit is defined" do
    before { Jammit }
    it     { should be_installed }
  end

  context "when Jammit is not defined" do
    before { Object.send(:remove_const, :Jammit) }
    it     { should_not be_installed }
  end

  def jammit_public_root
    defined?(Jammit.public_root) ? Jammit.public_root : Jammit::PUBLIC_ROOT
  end
end
