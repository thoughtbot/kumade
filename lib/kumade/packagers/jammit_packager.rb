begin
  require "jammit"
rescue LoadError
end

module Kumade
  class JammitPackager
    def self.assets_path
      File.join(Jammit::DEFAULT_PUBLIC_ROOT, Jammit.package_path)
    end

    def self.installed?
      !!defined?(Jammit)
    end

    def self.package
      Jammit.package!
    end
  end
end
