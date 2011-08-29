require 'rake'
require 'thor'

require 'kumade/base'
require 'kumade/git'
require 'kumade/deployer'
require 'kumade/runner'
require 'kumade/railtie'

module Kumade
  def self.on_cedar!(app)
    @cedar_apps ||= []
    @cedar_apps << app
  end

  def self.cedar?(app)
    @cedar_apps.include?(app)
  end
end
