# add rake tasks if we are inside Rails
if defined?(Rails::Railtie)
  class Module
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path("../../tasks/deploy.rake", __FILE__)
      end
    end
  end
end