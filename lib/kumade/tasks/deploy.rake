class Kumade
  desc "Alias for deploy:staging"
  task :deploy => 'deploy:staging'

  namespace :deploy do
    desc "Deploy to Heroku staging"
    task :staging => [:clean_git] do
      deployer.git_push('staging')
    end

    desc "Deploy to Heroku production"
    task :production => [:clean_git] do
      deployer.git_push('production')
    end

    task :clean_git do
      ensure_clean_git
    end
  end
end
