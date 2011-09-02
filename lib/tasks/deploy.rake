namespace :deploy do
  Kumade::Git.environments.each do |environment|
    desc "Deploy to #{environment} environment"
    task environment do
      Kumade::Runner.run([environment])
    end
  end
end