require "spec_helper"

require "less"

describe Kumade::MorePackager do
  subject { Kumade::MorePackager }

  before do
    define_constant "Less::More" do
      def self.destination_path
        "awesome_destination"
      end
    end
  end

  it_should_behave_like "packager"

  its(:assets_path) { should == File.join('public', ::Less::More.destination_path) }

  it "knows how to package itself" do
    Less::More.stubs(:generate_all)

    subject.package

    Less::More.should have_received(:generate_all).once
  end

  context "when More is defined" do
    before { Less::More }
    it     { should be_installed }
  end

  context "when Less::More is not defined" do
    before { Less.send(:remove_const, :More) }
    it     { should_not be_installed }
  end
end
