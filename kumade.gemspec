# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kumade/version"

Gem::Specification.new do |s|
  s.name        = "kumade"
  s.version     = Kumade::VERSION
  s.authors     = ["Gabe Berke-Williams", "thoughtbot"]
  s.email       = ["gabe@thoughtbot.com", "support@thoughtbot.com"]
  s.homepage    = "http://thoughtbot.com/community/"
  s.summary     = %q{A well-tested script for easy deploying to Heroku}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('heroku', '~> 2.0')
  s.add_dependency('thor', '~> 0.14')
  s.add_dependency('rake', '>= 0.8.7')
  s.add_dependency('cocaine', '>= 0.2.0')

  s.add_development_dependency('rake', '>= 0.8.7')
  s.add_development_dependency('rspec', '~> 2.6.0')
  s.add_development_dependency('cucumber', '~> 1.0.2')
  s.add_development_dependency('aruba', '~> 0.4.3')
  s.add_development_dependency('jammit', '~> 0.6.3')
end
