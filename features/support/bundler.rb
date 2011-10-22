module BundlerHelpers
  def run_bundler
    run_simple('bundle --gemfile=./Gemfile --local || bundle --gemfile=./Gemfile')
  end

  def add_jammit_to_gemfile
    append_to_file('Gemfile', "\ngem 'jammit'")
  end

  def add_kumade_to_gemfile
    append_to_file('Gemfile', "\ngem 'kumade', :path => '../../..'")
  end
end

World(BundlerHelpers)
