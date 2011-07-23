desc "Alias for deploy:staging"
task :deploy do
end

namespace :deploy do
  desc "Deploy to Heroku staging"
  task :staging do
  end

  desc "Deploy to Heroku production"
  task :production do
  end
end
