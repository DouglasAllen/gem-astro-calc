# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'astro_calc/version'

Gem::Specification.new do |spec|
  spec.name          = "astro_calc"
  spec.version       = AstroCalc::VERSION
  spec.authors       = ["Reuben Mallaby"]
  spec.email         = ["reuben@mallaby.me"]

  spec.summary       = %q{Astronomical gem to provide various calulations.}
  spec.homepage      = "http://mallaby.me/projects/astro_calc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
