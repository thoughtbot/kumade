class Kumade
  desc "Alias for deploy:staging"
  task :deploy => 'deploy:staging'

  namespace :deploy do
    desc "Deploy to Heroku staging"
    task :staging => :pre_deploy do
      deployer.git_push('staging')
    end

    desc "Deploy to Heroku production"
    task :production => :pre_deploy do
      deployer.git_push('production')
    end

    task :pre_deploy => [:clean_git, :rake_passes]

    task :clean_git do
      ensure_clean_git
    end

    task :rake_passes do
      ensure_rake_passes
    end
  end
end
