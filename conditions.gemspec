$:.push File.expand_path("../lib", __FILE__)
require "conditions/version"

Gem::Specification.new do |s|
  s.name        = "conditions"
  s.version     = Conditions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andre Gawron"]
  s.email       = ["andre@ziemek.de"]
  s.homepage    = "https://github.com/melkon/conditions"
  s.summary     = %q{Implements the Lisp's condition system in Ruby}
  s.description = %q{Implements the Lisp's condition system in Ruby}
  s.license     = 'BSD'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
