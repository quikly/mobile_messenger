# coding: utf-8
require File.expand_path('../lib/mobile_messenger/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "mobile_messenger"
  spec.version       = MobileMessenger::VERSION
  spec.authors       = ["Scott Meves"]
  spec.email         = ["scott@quikly.com"]
  spec.description   = "Provides a ruby interface for the Mobile Messenger API"
  spec.summary       = "Provides a ruby interface for the Mobile Messenger API"
  spec.homepage      = ""
  spec.license       = "MIT"

  #spec.files         = `git ls-files`.split($/)
  spec.files = %w(LICENSE.txt README.md Rakefile mobile_messenger.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")

  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.test_files = Dir.glob("spec/**/*")
  spec.require_paths = ["lib"]

  #spec.add_dependency 'activesupport', '~> 3.2'
  spec.add_development_dependency 'builder'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'webmock', '~> 3.1'
end
