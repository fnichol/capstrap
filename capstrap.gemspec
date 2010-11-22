# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capstrap/version"

Gem::Specification.new do |s|
  s.name        = "capstrap"
  s.version     = Capstrap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Fletcher Nichol"]
  s.email       = ["fnichol@nichol.ca"]
  s.homepage    = "http://rubygems.org/gems/capstrap"
  s.summary     = %q{bootstrapping chef solo from capistrano}
  s.description = %q{A command to remotely install git, rvm, ruby, and chef-solo using capistrano.}

  s.rubyforge_project = "capstrap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency              "thor",       "~> 0.14.3"
  s.add_dependency              "capistrano", "~> 2.5.19"

  s.add_development_dependency  "rspec",      "~>2.1.0"
  s.add_development_dependency  "yard",       "~>0.6.3"
end
