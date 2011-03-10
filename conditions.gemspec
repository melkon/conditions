# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "conditions/version"

Gem::Specification.new do |s|
  s.name        = "conditions"
  s.version     = Conditions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["André Gawron"]
  s.email       = ["andre@ziemek.de"]
  s.homepage    = "https://github.com/melkon/conditions"
  s.summary     = %q{Implements the Lisp's condition system in Ruby}
  s.description = %q{Implements the Lisp's condition system in Ruby}
  spec.license = 'BSD'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
