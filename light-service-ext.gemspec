# frozen_string_literal: true

require File.expand_path('lib/light-service-ext/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors = ["Desmond O'Leary"]
  gem.email = ["desoleary@gmail.com"]
  gem.description = 'Extends light-service with opinionated functionality'
  gem.summary = 'Extends light-service with opinionated functionality'
  gem.homepage = "https://github.com/omnitech-solutions/light-service-ext"
  gem.license = "MIT"

  gem.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables = gem.files.grep(%r{^exe/}).map { |f| File.basename(f) }
  gem.name = "light-service-ext"
  gem.require_paths = ["lib"]
  gem.version = LightServiceExt::VERSION
  gem.required_ruby_version = ">= 3.3"

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = gem.homepage
  gem.metadata["changelog_uri"] = "#{gem.homepage}/CHANGELOG.md"

  gem.add_dependency 'activesupport', '~> 6.0', '>= 6.0.6'
  gem.add_dependency 'dry-struct', '~> 1.6'
  gem.add_dependency 'dry-validation', '~> 1.10'
  gem.add_dependency 'json', '~> 2.6', '>= 2.6.3'
  gem.add_dependency 'light-service', '~> 0.18', '>= 0.18.0'

  # Development dependencies are managed in the Gemfile
  gem.metadata['rubygems_mfa_required'] = 'true'
end
