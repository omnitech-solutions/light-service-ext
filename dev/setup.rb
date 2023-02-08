# frozen_string_literal: true

# Sets up environment for running specs and via irb e.g. `$ irb -r ./dev/setup`

require 'light-service'
require 'dry-validation'

Dir.glob("lib/**/*.rb").each do |f|
  require File.join(__dir__, '..', f)
end

