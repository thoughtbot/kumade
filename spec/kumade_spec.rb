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

describe Kumade, ".outputter", :with_real_outputter => true do
  it "defaults to a Kumade::Outputter instance" do
    Kumade.outputter.should be_a Kumade::Outputter
  end
end

describe Kumade, ".outputter=", :with_real_outputter => true do
  it "sets Kumade.outputter" do
    Kumade.outputter = "new-value"
    Kumade.outputter.should == "new-value"
  end
end
