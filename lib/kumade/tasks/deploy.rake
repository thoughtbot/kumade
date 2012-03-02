namespace :deploy do
  Kumade::Git.environments.each do |environment|
    desc "Deploy to #{environment} environment"
    task environment do
      Kumade::CLI.new([environment])
    end
  end
end
