require 'thor'

class Kumade
  class ThorTask < Thor
    default_task :deploy

    desc "deploy [ENV]", "Deploy to ENV (default: staging)"
    method_option :pretend, :aliases => "-p", :desc => "Pretend Mode - print out what kumade would do"
    def deploy(environment = 'staging')
      say("==> In Pretend Mode", :red) if options[:pretend]
      say "==> Deploying to: #{environment}"

      case environment
      when 'staging'
        unless options[:pretend]
          Kumade.deployer.deploy_to_staging
        end
        say "==> Deployed to: staging", :green
      when 'production'
        unless options[:pretend]
          Kumade.deployer.deploy_to_production
        end
        say "==> Deployed to: production", :green
      else
        say "==> Cannot deploy: env must be either staging or production"
      end
    end
  end
end
