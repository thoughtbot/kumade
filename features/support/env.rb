begin
  require 'simplecov'
rescue LoadError
  # Probably on 1.8.7, ignore.
end
require 'aruba/cucumber'
require 'kumade'

Before('@slow') do
  @aruba_timeout_seconds = 60
end

After('@slow') do
  @aruba_timeout_seconds = Aruba::Api::DEFAULT_TIMEOUT_SECONDS
end
