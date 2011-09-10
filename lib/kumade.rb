module Kumade
  autoload :Base,            "kumade/base"
  autoload :Git,             "kumade/git"
  autoload :Deployer,        "kumade/deployer"
  autoload :CLI,             "kumade/cli"
  autoload :Railtie,         "kumade/railtie"
  autoload :DeploymentError, "kumade/deployment_error"
  autoload :Configuration,   "kumade/configuration"

  def self.configuration
    @@configuration ||= Kumade::Configuration.new
  end
end
