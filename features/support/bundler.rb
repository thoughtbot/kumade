module BundlerHelpers
  def run_bundler
    run_simple('bundle --gemfile=./Gemfile --local || bundle --gemfile=./Gemfile')
  end
end

World(BundlerHelpers)
