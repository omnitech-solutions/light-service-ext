# frozen_string_literal: true

module LightServiceExt
  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:allow_raise_on_failure) { true }
    config_accessor(:non_fatal_error_classes) { [] }
    config_accessor(:default_non_fatal_error_classes) { ['Rails::ActiveRecordError'.safe_constantize] }
    config_accessor(:logger) { (defined? Rails.logger).nil? ? Logger.new($stdout) : Rails.logger }

    def allow_raise_on_failure?
      !!allow_raise_on_failure
    end

    def non_fatal_errors
      (default_non_fatal_error_classes + non_fatal_error_classes).compact.uniq.map(&:to_s).freeze
    end

    def fatal_error?(exception)
      !non_fatal_errors.exclude?(exception.class.name)
    end

    def non_fatal_error?(exception)
      non_fatal_errors.include?(exception.class.name)
    end
  end
end
