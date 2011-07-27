class Kumade
  desc "Alias for kumade:deploy"
  task :deploy => "kumade:deploy"

  namespace :deploy do
    desc "Alias for kumade:deploy:staging"
    task :staging => "kumade:deploy:staging"

    desc "Alias for kumade:deploy:production"
    task :production => "kumade:deploy:production"
  end
end
