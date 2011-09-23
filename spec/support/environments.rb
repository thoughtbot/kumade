module EnvironmentHelpers
  shared_context "with Heroku environment" do
    let(:environment) { 'staging' }
    before do
      force_add_heroku_remote(environment)
      Kumade.configuration.environment = environment
    end

    after { remove_remote(environment) }
  end

  shared_context "with Heroku-accounts environment" do
    let(:environment) { 'heroku-accounts' }
    let(:heroku_url)  { 'git@heroku.work:my-app.git' }
    before do
      `git remote add #{environment} #{heroku_url}`
      Kumade.configuration.environment = environment
    end
    after { remove_remote(environment) }
  end

  shared_context "with non-Heroku environment" do
    let(:environment)      { 'not-heroku' }
    let(:not_a_heroku_url) { 'git@github.com:gabebw/kumade.git' }

    before do
      `git remote add #{environment} #{not_a_heroku_url}`
      Kumade.configuration.environment = environment
    end
    after { remove_remote(environment) }
  end
end
