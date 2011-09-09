require 'rspec'
require 'kumade'
require 'rake'
require 'stringio'
require 'aruba/api'
require 'cocaine'

module GitRemoteHelpers
  def force_add_heroku_remote(remote_name)
    remove_remote(remote_name)
    `git remote add #{remote_name} git@heroku.com:#{remote_name}.git`
  end

  def remove_remote(remote_name)
    `git remote rm #{remote_name} 2>/dev/null`
  end
end

RSpec.configure do |config|
  config.include RSpec::Mocks::Methods
  config.include GitRemoteHelpers
  config.include Aruba::Api

  config.around do |example|
    FileUtils.rm_rf(current_dir)
    FileUtils.mkdir_p(current_dir)
    in_current_dir do
      `git init .`
      `touch .gitkeep`
      `git add .`
      `git commit -m First`
      example.run
    end
  end
end
