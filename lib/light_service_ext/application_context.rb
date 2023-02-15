module LightServiceExt
  class ApplicationContext < LightService::Context
    OVERRIDABLE_DEFAULT_KEYS = %i[errors params allow_raise_on_failure].freeze

    class << self
      def make_with_defaults(input = {}, overrides = {})
        allowed_overrides = overrides.slice(*OVERRIDABLE_DEFAULT_KEYS)
        make({ input: input.symbolize_keys }.merge(default_attrs, allowed_overrides))
      end

      private

      def default_attrs
        { errors: {}, params: {}, successful_actions: [], api_responses: [], allow_raise_on_failure: true }.freeze
      end
    end

    def invoked_action
      self[:invoked_action]
    end

    def validation_errors
      self[:errors]
    end

    def allow_raise_on_failure?
      !!self[:allow_raise_on_failure]
    end

    def method_missing(method_name, *arguments, &block)
      return self[method_name] if key?(method_name)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      key?(method_name) || super
    end
  end
end
