require 'spec_helper'

describe Kumade, ".app_for" do
  let(:environment){ 'staging' }
  let(:app_name){ 'staging_test' }

  before { add_heroku_remote(environment, app_name) }
  after  { remove_remote(environment) }

  it "autodetects the Heroku app name" do
    Kumade.app_for(environment).should == app_name
  end

  it "returns an empty string if the app cannot be found" do
    Kumade.app_for('xyz').should == ""
  end
end

describe Kumade, "heroku_remote_url_for_app" do
  it "returns the Heroku remote_url for an app" do
    Kumade.heroku_remote_url_for_app('blerg').should == 'git@heroku.com:blerg.git'
  end
end
