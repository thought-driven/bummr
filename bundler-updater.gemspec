# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/updater/version'

Gem::Specification.new do |spec|
  spec.name          = "bundler-updater"
  spec.version       = Bundler::Updater::VERSION
  spec.authors       = ["Ryan Sonnek"]
  spec.email         = ["ryan@codecrate.com"]
  spec.summary       = %q{Helper script to intelligently update your Gemfile}
  spec.description   = %q{Don't update *all* of your gems at once.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
