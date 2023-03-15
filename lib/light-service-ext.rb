# frozen_string_literal: true

require 'json'
require 'light-service'
require 'dry-validation'
require 'active_support/core_ext/array'
require 'active_support/configurable'


%w[
version
constants
regex
error_info
context_error
configuration
with_error_handler
record_actions
application_context
application_contract
around_action_execute_extension
application_action
all_actions_complete_action
application_validator_action
application_organizer
application_orchestrator
].each do |filename|
  require File.expand_path("../light-service-ext/#{filename}", Pathname.new(__FILE__).realpath)
end



module LightServiceExt
  class << self
    def config
      self.configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
