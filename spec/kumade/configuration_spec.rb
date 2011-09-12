require 'spec_helper'

describe Kumade::Configuration, "by default" do
  its(:environment) { should == 'staging' }
  it { should_not be_pretending }
end

describe Kumade::Configuration, "#pretending" do
  it "has read/write access for the pretending attribute" do
    subject.pretending = true
    subject.pretending.should == true
  end
end

describe Kumade::Configuration, "#tests" do
  it "has read/write access for the tests attribute" do
    subject.tests = true
    subject.tests.should == true
  end
end

describe Kumade::Configuration, "#tests?" do
  it "returns false when not testing" do
    subject.tests = false
    subject.tests?.should be_false
  end

  it "returns true when testing" do
    subject.tests = true
    subject.tests?.should be_true
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
    subject.pretending.should == false
  end
end

describe Kumade::Configuration, "#environment" do
  it "has read/write access for the environment attribute" do
    subject.environment = 'new-environment'
    subject.environment.should == 'new-environment'
  end
end
