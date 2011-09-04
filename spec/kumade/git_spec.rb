require 'spec_helper'

describe Kumade::Git, "#heroku_remote?" do
  let(:environment){ 'staging' }
  let(:another_heroku_environment){ 'another_staging' }
  let(:not_a_heroku_env){ 'fake_heroku' }
  let(:not_a_heroku_url){ 'git@github.com:gabebw/kumade.git' }
  let(:another_heroku_url){ 'git@heroku.work:my-app.git' }

  before do
    force_add_heroku_remote(environment)
    `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
    `git remote add #{another_heroku_environment} #{another_heroku_url}`
  end
  after do
    remove_remote(environment)
    remove_remote(not_a_heroku_env)
    remove_remote(another_heroku_environment)
  end

  it "should return true when environment remote is a heroku repository" do
    Kumade::Git.new(false, environment).heroku_remote?.should be_true
    Kumade::Git.new(false, another_heroku_environment).heroku_remote?.should be_true
  end

  it "should return false when environment remote isn't a heroku repository" do
    Kumade::Git.new(false, 'kumade').heroku_remote?.should be_false
  end

end

describe Kumade::Git, ".environments" do
  let(:environment){ 'staging' }
  let(:not_a_heroku_env){ 'fake_heroku' }
  let(:not_a_heroku_url){ 'git@github.com:gabebw/kumade.git' }

  before do
    force_add_heroku_remote(environment)
    `git remote add #{not_a_heroku_env} #{not_a_heroku_url}`
  end
  after do
    remove_remote(environment)
    remove_remote(not_a_heroku_env)
  end

  it "should return all environments" do
    Kumade::Git.environments.should == ["staging"]
  end
end
