# frozen_string_literal: true

# Sets up environment for running specs and via irb e.g. `$ irb -r ./dev/setup`

require "pathname"
require "rspec/core"

require File.expand_path("../../lib/light-service-ext", Pathname.new(__FILE__).realpath)
require File.expand_path("../../spec/spec_helper", Pathname.new(__FILE__).realpath)
