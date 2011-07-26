Given /^I stub out the "([^"]+)" deploy method$/ do |environment|
  append_to_file("Rakefile", <<-RAKE)

  class Kumade::Deployer
    def deploy_to_#{environment}
      puts "Force pushed master -> #{environment}"
    end
  end
  RAKE
end
