class Kumade
  desc "Alias for deploy:staging"
  task :deploy => 'deploy:staging'

  namespace :deploy do
    desc "Deploy to Heroku staging"
    task :staging => :pre_deploy do
      deployer.git_force_push('staging')
    end

    desc "Deploy to Heroku production"
    task :production => :pre_deploy do
      deployer.git_force_push('production')
    end

    task :pre_deploy => [:clean_git, :rake_passes, :package_assets] do
      deployer.git_push('origin')
    end

    task :clean_git do
      deployer.ensure_clean_git
    end

    task :rake_passes do
      deployer.ensure_rake_passes
    end
  end
end
