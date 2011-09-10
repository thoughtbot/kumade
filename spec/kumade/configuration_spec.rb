require 'spec_helper'

describe Kumade::Configuration do
  context "#pretending" do
    it "has read/write access for the pretending attribute" do
      subject.pretending = true
      subject.pretending.should == true
    end
  end

  context "pretending?" do
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

  context "#environment" do
    it "has read/write access for the environment attribute" do
      subject.environment = 'new-environment'
      subject.environment.should == 'new-environment'
    end

    it "defaults to staging" do
      subject.environment.should == 'staging'
    end
  end
end
