begin
  require "less/more"
rescue LoadError
end

module Kumade
  class MorePackager
    def self.assets_path
      File.join("public", ::Less::More.destination_path)
    end

    def self.installed?
      !!defined?(Less::More)
    end

    def self.package
      ::Less::More.generate_all
    end
  end
end
