require 'spec_helper'

describe Kumade::Configuration, "by default", :with_mock_outputter do
  its(:environment) { should == 'staging' }
  it { should_not be_pretending }
end

describe Kumade::Configuration, "#pretending", :with_mock_outputter do
  it "has read/write access for the pretending attribute" do
    subject.pretending = true
    subject.should be_pretending
  end
end

describe Kumade::Configuration, "#pretending?", :with_mock_outputter do
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

describe Kumade::Configuration, "#environment", :with_mock_outputter do
  it "has read/write access for the environment attribute" do
    subject.environment = 'new-environment'
    subject.environment.should == 'new-environment'
  end
end
