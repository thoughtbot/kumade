require 'rake'
require 'thor'
require 'stringio'

require 'kumade/deployer'
require 'kumade/runner'
require 'kumade/railtie'
require 'kumade/deployment_error'

module Kumade
  def self.app_for(environment)
    heroku_git_url = `git config --get remote.#{environment}.url`.strip
    if heroku_git_url =~ /^git@heroku\.com:(.+)\.git$/
      $1
    else
      nil
    end
  end
  def self.environments
    url_remotes = `git remote`.strip.split("\n").map{|remote| [remote, `git config --get remote.#{remote}.url`.strip] }.select{|remote| remote.last =~ /^git@heroku\.com:(.+)\.git$/}.map{|remote| remote.first}
  end
end
