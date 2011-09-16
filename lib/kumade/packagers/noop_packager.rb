module Kumade
  class NoopPackager
    def self.assets_path
      ""
    end

    def self.package
    end

    def self.installed?
      false
    end
  end
end
