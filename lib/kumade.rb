module Kumade
  autoload :Base,            "kumade/base"
  autoload :Git,             "kumade/git"
  autoload :Deployer,        "kumade/deployer"
  autoload :CLI,             "kumade/cli"
  autoload :Railtie,         "kumade/railtie"
  autoload :DeploymentError, "kumade/deployment_error"
  autoload :Configuration,   "kumade/configuration"
  autoload :Heroku,          "kumade/heroku"

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configuration=(new_configuration)
    @@configuration = new_configuration
  end
end
