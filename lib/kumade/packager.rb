module Kumade
  class Packager
    def initialize(git, packager = Packager.available_packager)
      @packager = packager
      @git      = git
    end

    def run
      if @packager.installed?
        precompile_assets
        package
      end
    end

    def self.available_packager
      Kumade::PackagerList.new.first
    end

    private

    def precompile_assets
      RakeTaskRunner.new("kumade:before_asset_compilation").invoke
    end

    def package
      return Kumade.configuration.outputter.success(success_message) if Kumade.configuration.pretending?

      begin
        @packager.package
        if @git.dirty? || @git.has_untracked_files_in?(@packager.assets_path)
          @git.add_and_commit_all_assets_in(@packager.assets_path)
          Kumade.configuration.outputter.success(success_message)
        end
      rescue => packager_exception
        Kumade.configuration.outputter.error("Error: #{packager_exception.class}: #{packager_exception.message}")
      end
    end

    def success_message
      "Packaged with #{@packager.name}"
    end
  end
end
