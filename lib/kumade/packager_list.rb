module Kumade
  class PackagerList
    include Enumerable

    PACKAGERS = [JammitPackager]

    def initialize
      @packagers = build_packagers_list
    end

    def each(&block)
      @packagers.each(&block)
    end

    private

    def build_packagers_list
      if installed_packagers.any?
        installed_packagers
      else
        [NoopPackager]
      end
    end

    def installed_packagers
      PACKAGERS.select(&:installed?)
    end
  end
end
