module Kumade
  class Packager
    def initialize(git, packager = Packager.available_packager)
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
      RakeTaskRunner.new("kumade:before_asset_compilation").invoke
    end

    def package
      return Kumade.outputter.success(success_message) if Kumade.configuration.pretending?

      begin
        @packager.package
        if @git.dirty?
          @git.add_and_commit_all_assets_in(@packager.assets_path)
          Kumade.outputter.success(success_message)
        end
      rescue => packager_exception
        Kumade.outputter.error("Error: #{packager_exception.class}: #{packager_exception.message}")
      end
    end

    def success_message
      "Packaged with #{@packager.name}"
    end
  end
end
