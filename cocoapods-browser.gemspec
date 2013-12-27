# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods/browser/version'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-browser"
  spec.version       = Cocoapods::Browser::VERSION
  spec.authors       = ["Toshihiro Morimoto"]
  spec.email         = ["dealforest.net@gmail.com"]
  spec.description   = %q{CocoaPods plugin to open a pod's homepage on the browser.}
  spec.summary       = %q{Open a pod's homepage on brwoser}
  spec.homepage      = "https://github.com/dealforest/cocoapods-browser"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency 'cocoapods'
end
