require 'spec_helper'

describe Kumade::PackagerList, "detecting packages", :with_mock_outputter do
  it "returns an array containing the Jammit packager if Jammit is installed" do
    Kumade::JammitPackager.stubs(:installed? => true)

    Kumade::PackagerList.new.to_a.should == [Kumade::JammitPackager]
  end

  it "returns an array containing the no-op packager if no other packagers are found" do
    Kumade::JammitPackager.stubs(:installed? => false)

    Kumade::PackagerList.new.to_a.should == [Kumade::NoopPackager]
  end
end
