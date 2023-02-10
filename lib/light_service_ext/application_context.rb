module LightServiceExt
  class ApplicationContext < LightService::Context
    class << self
      def make_with_defaults(ctx)
        make({ input: ctx.symbolize_keys, errors: {}, params: {}, successful_actions: [], api_responses: [],
               raise_on_failure: true })
      end
    end

    def invoked_action
      self[:invoked_action]
    end

    def validation_errors
      self[:errors]
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
