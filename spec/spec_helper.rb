require 'rspec'
require 'kumade'
require 'rake'
require 'stringio'

module GitRemoteHelpers
  def force_add_heroku_remote(remote_name, app_name)
    remove_remote(remote_name)
    `git remote add #{remote_name} git@heroku.com:#{app_name}.git`
  end

  def remove_remote(remote_name)
    `git remote rm #{remote_name} 2>/dev/null`
  end
end

RSpec.configure do |config|
  config.include RSpec::Mocks::Methods
  config.include GitRemoteHelpers
end
