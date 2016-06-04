# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bummr/version'

Gem::Specification.new do |spec|
  spec.name          = "bummr"
  spec.version       = Bummr::VERSION
  spec.authors       = ["Lee Pender"]
  spec.email         = ["lpender@gmail.com"]
  spec.summary       = %q{Helper script to intelligently update your Gemfile}
  spec.description   = %q{See Readme}
  spec.homepage      = "https://github.com/lpender/bummr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', "~> 0.19"
  spec.add_dependency 'colorize', "~> 0.7"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', "~> 0"
  spec.add_development_dependency 'pry', "~> 0"
end
