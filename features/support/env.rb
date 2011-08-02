require 'aruba/cucumber'
require 'kumade'

Before('@extra-timeout') do
  # Default is 3
  @aruba_timeout_seconds = 5
end
