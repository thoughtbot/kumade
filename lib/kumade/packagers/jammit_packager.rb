begin
  require "jammit"
rescue LoadError
end

module Kumade
  class JammitPackager
    def self.assets_path
      File.join(public_root, Jammit.package_path)
    end

    def self.installed?
      !!defined?(Jammit)
    end

    def self.package
      Jammit.package!
    end

    private

    def self.public_root
      defined?(Jammit.public_root) ? Jammit.public_root : Jammit::PUBLIC_ROOT
    end
  end
end
