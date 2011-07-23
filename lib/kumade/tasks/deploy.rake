class Kumade
  desc "Alias for deploy:staging"
  task :deploy => 'deploy:staging'

  namespace :deploy do
    desc "Deploy to Heroku staging"
    task :staging do
      deployer.git_push('staging')
    end

    desc "Deploy to Heroku production"
    task :production do
      deployer.git_push('production')
    end
  end
end
