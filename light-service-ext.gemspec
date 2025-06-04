# frozen_string_literal: true

require File.expand_path('../lib/light-service-ext/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ["Desmond O'Leary"]
  gem.email = ["desoleary@gmail.com"]
  gem.description = %q{Extends light-service with opinionated functionality}
  gem.summary = %q{Extends light-service with opinionated functionality}
  gem.homepage = "https://github.com/omnitech-solutions/light-service-ext"
  gem.license = "MIT"

  gem.files = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^exe/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.name = "light-service-ext"
  gem.require_paths = ["lib"]
  gem.version = LightServiceExt::VERSION
  gem.required_ruby_version = ">= 2.7"

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = gem.homepage
  gem.metadata["changelog_uri"] = "#{gem.homepage}/CHANGELOG.md"

  gem.add_runtime_dependency 'light-service', '~> 0.18', '>= 0.18.0'
  gem.add_runtime_dependency 'dry-struct', '~> 1.6'
  gem.add_runtime_dependency 'dry-validation', '~> 1.10'
  gem.add_runtime_dependency 'json', '~> 2.6', '>= 2.6.3'
  gem.add_runtime_dependency 'activesupport', '~> 6.0', '>= 6.0.6'
  gem.add_runtime_dependency 'thor', '~> 1.2'

  gem.add_development_dependency("rake", "~> 13.0.6")
  gem.add_development_dependency("rspec", "~> 3.12.0")
  gem.add_development_dependency("simplecov", "~> 0.21.2")
  gem.add_development_dependency("codecov", "~> 0.6.0")
end
