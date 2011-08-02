require 'spec_helper'

describe Kumade, ".app_for" do
  let(:environment){ 'staging' }
  let(:app_name){ 'staging_test' }
  let(:not_a_heroku_env){ 'fake_heroku' }
  let(:not_a_heroku_url){ 'git@github.com:gabebw/kumade.git' }

  before do
    force_add_heroku_remote(environment, app_name)
    `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
  end
  after do
    remove_remote(environment)
    remove_remote(not_a_heroku_env)
  end

  it "autodetects the Heroku app name" do
    Kumade.app_for(environment).should == app_name
  end

  it "is nil if the app cannot be found" do
    Kumade.app_for('xyz').should be_nil
  end

  it "is nil if the remote is not a Heroku remote" do
    Kumade.app_for(not_a_heroku_env).should be_nil
  end
end
