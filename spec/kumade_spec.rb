require 'spec_helper'

describe Kumade, ".configuration" do
  it "returns a Kumade::Configuration instance" do
    Kumade.configuration.should be_a Kumade::Configuration
  end

  it "caches the configuration" do
    Kumade.configuration.should eq Kumade.configuration
  end
end

describe Kumade, ".configuration=" do
  it "sets Kumade.configuration" do
    Kumade.configuration = "new-value"
    Kumade.configuration.should == "new-value"
  end
end
