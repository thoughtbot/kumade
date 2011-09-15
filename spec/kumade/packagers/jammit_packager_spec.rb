require "spec_helper"

require "jammit"

describe Kumade::JammitPackager do
  subject { Kumade::JammitPackager }

  it_should_behave_like "packager"

  its(:assets_path) { should == File.join(Jammit::PUBLIC_ROOT, Jammit.package_path) }

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
end
