module Kumade
  class Packager < Base
    def initialize(git, packager = Packager.available_packager)
      super()
      @packager = packager
      @git      = git
    end

    def run
      precompile_assets
      package
    end

    def self.available_packager
      Kumade::PackagerList.new.first
    end

    private

    def precompile_assets
      RakeTaskRunner.new("kumade:before_asset_compilation", self).invoke
    end

    def package
      return success(success_message) if Kumade.configuration.pretending?

      begin
        @packager.package
        if @git.dirty?
          git_add_and_commit_all_assets_in(@packager.assets_path)
          success(success_message)
        end
      rescue => packager_exception
        error("Error: #{packager_exception.class}: #{packager_exception.message}")
      end
    end

    def success_message
      "Packaged with #{@packager.name}"
    end

    def git_add_and_commit_all_assets_in(dir)
      @git.add_and_commit_all_in(dir, Kumade::Heroku::DEPLOY_BRANCH, 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    end
  end
end