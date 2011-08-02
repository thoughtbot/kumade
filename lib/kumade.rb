require 'thor'

require 'kumade/deployer'
require 'kumade/thor_task'

module Kumade
  def self.app_for(environment)
    heroku_git_url = `git config --get remote.#{environment}.url`.strip
    if heroku_git_url =~ /^git@heroku\.com:(.+)\.git$/
      $1
    else
      nil
    end
  end
end
