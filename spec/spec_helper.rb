require 'rspec'
require 'aruba/api'
require 'bourne'

require 'kumade'

# Since we autoload, these aren't require'd when we require kumade.
require 'rake'
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


spec_dir = Pathname.new(File.expand_path(File.dirname(__FILE__)))
Dir[spec_dir.join('support', '**', "*.rb")].each {|f| require File.expand_path(f) }

RSpec.configure do |config|
  config.mock_with :mocha
  config.color_enabled = true

  config.include Rake::DSL if defined?(Rake::DSL)

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

  config.after do
    Kumade.configuration = Kumade::Configuration.new
  end
end
