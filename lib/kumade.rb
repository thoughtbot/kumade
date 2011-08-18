require 'thor'
require 'kumade/deployer'
require 'kumade/runner'
require 'kumade/railtie'

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

  def self.on_cedar!(app)
    @cedar_apps ||= []
    @cedar_apps << app
  end

  def self.cedar?(app)
    @cedar_apps.include?(app)
  end
end
