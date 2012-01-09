begin
  require 'simplecov'
rescue LoadError
  # Probably on 1.8.7, ignore.
end
require 'aruba/cucumber'
require 'kumade'

Before do
  @aruba_timeout_seconds = 60
end
