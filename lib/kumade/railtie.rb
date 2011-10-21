if defined?(Rails::Railtie)
  module Kumade
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "kumade/tasks/deploy.rake"
      end
    end
  end
end
