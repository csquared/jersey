# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jersey/version'

Gem::Specification.new do |spec|
  spec.name          = "jersey"
  spec.version       = Jersey::VERSION
  spec.authors       = ["csquared"]
  spec.email         = ["christopher.continanza@gmail.com"]
  spec.summary       = %q{Write APIs in the New Jersey Style}
  spec.description   = %q{Set of composable middleware and helpers for production sinatra APIs}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency 'sinatra-contrib', "~> 1.4"
  spec.add_dependency 'env-conf'
  spec.add_dependency 'request_store'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
