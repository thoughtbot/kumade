module Kumade
  autoload :Base,            "kumade/base"
  autoload :Git,             "kumade/git"
  autoload :Packager,        "kumade/packager"
  autoload :Deployer,        "kumade/deployer"
  autoload :CLI,             "kumade/cli"
  autoload :Railtie,         "kumade/railtie"
  autoload :DeploymentError, "kumade/deployment_error"
  autoload :Configuration,   "kumade/configuration"

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configuration=(new_configuration)
    @@configuration = new_configuration
  end
end