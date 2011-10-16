begin
  require 'simplecov'
rescue LoadError
  # Probably on 1.8.7, ignore.
end
require 'aruba/cucumber'
require 'kumade'

Before('@extra-timeout') do
  @aruba_timeout_seconds = 15
end
