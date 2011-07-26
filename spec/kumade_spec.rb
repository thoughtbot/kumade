require 'spec_helper'

describe Kumade, "staging remote" do
  before { Kumade.reset_remotes! }
  it "defaults to staging" do
    Kumade.staging.should == 'staging'
  end

  it "can be set" do
    Kumade.staging = 'orange'
    Kumade.staging.should == 'orange'
  end
end

describe Kumade, "production remote" do
  before { Kumade.reset_remotes! }

  it "defaults to production" do
    Kumade.production.should == 'production'
  end

  it "can be set" do
    Kumade.production = 'orange'
    Kumade.production.should == 'orange'
  end
end
