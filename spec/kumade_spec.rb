require 'spec_helper'

describe Kumade, ".staging_remote" do
  let(:staging_app){ 'purple' }
  let(:staging_remote){ 'staging_test' }

  before do
    Kumade.reset!
    `git remote add #{staging_remote} git@heroku.com:#{staging_app}.git`
  end

  after { `git remote rm #{staging_remote}` }

  it "can be set" do
    Kumade.staging_remote = 'orange'
    Kumade.staging_remote.should == 'orange'
  end

  it "is autodetected if staging app is set" do
    Kumade.staging_app = staging_app
    Kumade.staging_remote.should == staging_remote
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

describe Kumade, ".production_remote" do
  let(:production_app){ 'purple' }
  let(:production_remote){ 'production_test' }

  before do
    Kumade.reset!
    `git remote add #{production_remote} git@heroku.com:#{production_app}.git`
  end

  after { `git remote rm #{production_remote}` }

  it "can be set" do
    Kumade.production_remote = 'orange'
    Kumade.production_remote.should == 'orange'
  end

  it "is autodetected if production app is set" do
    Kumade.production_app = production_app
    Kumade.production_remote.should == production_remote
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

describe Kumade, "heroku_remote_url_for_app" do
  it "returns the Heroku remote_url for an app" do
    Kumade.heroku_remote_url_for_app('blerg').should == 'git@heroku.com:blerg.git'
  end
end
