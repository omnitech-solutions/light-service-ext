# frozen_string_literal: true

module LightServiceExt
  class ApplicationContext < LightService::Context
    attr_reader :error_info

    class << self
      def make_with_defaults(input = {}, overrides = {})
        defaults = default_attrs
        allowed_override_keys = defaults.keys.excluding(:input)
        allowed_overrides = overrides.slice(*allowed_override_keys)
        make({ input: input.symbolize_keys }.merge(defaults, allowed_overrides))
      end

      private

      def default_attrs
        {
          errors: {},
          params: {},
          status: Status::INCOMPLETE,
          invoked_action: nil,
          successful_actions: [],
          current_api_response: nil,
          api_responses: [],
          last_failed_context: nil,
          allow_raise_on_failure: LightServiceExt.config.allow_raise_on_failure?,
          internal_only: {},
          meta: {}
        }.freeze
      end
    end

    def add_params(**params)
      add_attrs_to_ctx(:params, **params)
    end

    def add_errors(**errors)
      add_attrs_to_ctx(:errors, **errors)
    end

    def add_errors!(**errors)
      return if errors.blank?

      add_errors(**errors)
      fail_and_return!
    end

    def add_status(status)
      add_value_to_ctx(:status, status)
    end

    def add_current_api_response(api_response)
      add_value_to_ctx(:current_api_response, api_response)
    end

    def add_last_failed_context(failed_context)
      return if failed_context.nil? || failed_context.try(:success?)

      add_value_to_ctx(:last_failed_context, failed_context)
    end

    def add_internal_only(**attrs)
      add_attrs_to_ctx(:internal_only, **attrs)
    end

    def add_meta(**attrs)
      add_attrs_to_ctx(:meta, **attrs)
    end

    def record_raised_error(error)
      @error_info = ErrorInfo.new(error)
      error_type = @error_info.type
      error_message = @error_info.message
      add_internal_only(error_info: { organizer: organizer_name,
                                      action_name: action_name,
                                      error: { type: error_type, message: error_message,
                                               backtrace: @error_info.clean_backtrace } })
      add_errors(base: error_message)

      LightServiceExt.config.on_raised_error.call(self, error)
    end

    def add_to_api_responses(*api_response)
      add_collection_to_ctx(:api_responses, *api_response)
    end

    def add_to_successful_actions(*action_name)
      add_collection_to_ctx(:successful_actions, *action_name)
    end

    def add_invoked_action(invoked_action)
      add_value_to_ctx(:invoked_action, invoked_action)
    end

    def allow_raise_on_failure?
      !!self[:allow_raise_on_failure]
    end

    def organizer_name
      return nil if organized_by.nil?

      organized_by.name.split("::").last
    end

    def action_name
      return nil if invoked_action.blank?

      invoked_action.name.split("::").last
    end

    def formatted_errors
      JSON.pretty_generate(errors.presence || {})
    end

    private

    def add_value_to_ctx(key, value)
      self[key] = value
      nil
    end

    def add_attrs_to_ctx(key, **attrs)
      return if attrs.blank?

      self[key].merge!(attrs)
      nil
    end

    def add_collection_to_ctx(key, *values)
      return if values.empty?

      self[key] = self[key].concat(values).compact
      nil
    end

    def method_missing(method_name, *arguments, &)
      return self[method_name] if key?(method_name)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      key?(method_name) || super
    end
  end
end
