module BundlerHelpers
  def run_bundler
    bundle = 'bundle install'
    run_simple("#{bundle} --local || #{bundle}")
  end

  def add_jammit_to_gemfile
    append_to_file('Gemfile', "\ngem 'jammit'")
  end

  def add_kumade_to_gemfile
    append_to_file('Gemfile', "\ngem 'kumade', :path => '../../..'")
  end
end

World(BundlerHelpers)
