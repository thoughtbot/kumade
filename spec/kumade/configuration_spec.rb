require 'spec_helper'

describe Kumade::Configuration, "by default" do
  its(:environment) { should == 'staging' }
  it { should_not be_pretending }
end

describe Kumade::Configuration, "#outputter" do
  it "defaults to a Kumade::Outputter instance" do
    subject.outputter.should be_a Kumade::Outputter
  end
end

describe Kumade::Configuration, "#outputter=" do
  it "sets outputter" do
    subject.outputter = "new-value"
    subject.outputter.should == "new-value"
  end
end

describe Kumade::Configuration, "#pretending" do
  it "has read/write access for the pretending attribute" do
    subject.pretending = true
    subject.should be_pretending
  end
end

describe Kumade::Configuration, "#pretending?" do
  it "returns false when not pretending" do
    subject.pretending = false
    subject.should_not be_pretending
  end

  it "returns true when pretending" do
    subject.pretending = true
    subject.should be_pretending
  end

  it "defaults to false" do
    subject.should_not be_pretending
  end
end

describe Kumade::Configuration, "#environment" do
  it "has read/write access for the environment attribute" do
    subject.environment = 'new-environment'
    subject.environment.should == 'new-environment'
  end
end
