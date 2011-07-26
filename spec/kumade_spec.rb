require 'spec_helper'

describe Kumade, "staging remote" do
  before { Kumade.reset! }
  it "defaults to staging" do
    Kumade.staging.should == 'staging'
  end

  it "can be set" do
    Kumade.staging = 'orange'
    Kumade.staging.should == 'orange'
  end
end

describe Kumade, "staging app" do
  before { Kumade.reset! }

  it "defaults to nil" do
    Kumade.staging_app.should be_nil
  end

  it "can be set" do
    Kumade.staging_app = 'orange'
    Kumade.staging_app.should == 'orange'
  end
end

describe Kumade, "production remote" do
  before { Kumade.reset! }

  it "defaults to production" do
    Kumade.production.should == 'production'
  end

  it "can be set" do
    Kumade.production = 'orange'
    Kumade.production.should == 'orange'
  end
end

describe Kumade, "production app" do
  before { Kumade.reset! }

  it "defaults to nil" do
    Kumade.production_app.should be_nil
  end

  it "can be set" do
    Kumade.production_app = 'orange'
    Kumade.production_app.should == 'orange'
  end
end
