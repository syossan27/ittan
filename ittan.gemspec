# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ittan/version'

Gem::Specification.new do |spec|
  spec.name          = "ittan"
  spec.version       = Ittan::VERSION
  spec.authors       = ["syossan27"]
  spec.email         = ["wisdom1027@gmail.com"]

  spec.summary       = %q{Generate database dummy seed data.}
  spec.description   = %q{Generate database dummy seed data.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "thor", "~> 0.19.4"
  spec.add_development_dependency "tod", "~> 0.2.0"
  spec.add_development_dependency "activesupport", "~> 5.0.0.1"
end
