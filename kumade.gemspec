# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kumade/version"

Gem::Specification.new do |s|
  s.name        = "kumade"
  s.version     = Kumade::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gabe Berke-Williams"]
  s.email       = ["gabe@thoughtbot.com"]
  s.homepage    = ""
  s.summary     = %q{Simple rake tasks for deploying to Heroku}
  s.description = %q{Simple rake tasks for deploying to Heroku}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "kumade"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec', '~> 2.6.0')
  s.add_development_dependency('cucumber', '~> 1.0.2')
  s.add_development_dependency('aruba', '~> 0.4.3')
end
