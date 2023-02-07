# frozen_string_literal: true

require 'light-service'
require 'dry-validation'

Dir.glob("lib/**/*.rb").each { |f| require File.join(__dir__, "..", f) }

require 'coverage_helper'
require 'light-service/testing'

require "light_service_ext"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
