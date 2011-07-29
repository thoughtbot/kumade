require 'kumade/deployer'
require 'kumade/thor_task'

class Kumade
  def self.deployer
    @deployer ||= Deployer.new
  end

  def self.app_for(environment)
    heroku_git_url = `git remote show -n #{environment} | grep 'Push  URL' | cut -d' ' -f6`.strip
    match = heroku_git_url.match(/:(.+)\.git$/)
    if match
      match[1]
    else
      ""
    end
  end

  def self.heroku_remote_url_for_app(app_name)
    "git@heroku.com:#{app_name}.git"
  end
end
