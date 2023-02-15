# frozen_string_literal: true

module LightServiceExt
  class ContextError < StandardError
    attr_reader :error_info, :context, :error

    delegate :organized_by, :invoked_action, :errors, to: :context, allow_nil: true
    delegate :fatal_error?, :backtrace, to: :error_info

    alias organizer organized_by
    alias action invoked_action

    def initialize(ctx:, error: nil, message: nil, fatal: false)
      super
      @error = error
      @context = ctx
      message = message.presence || "Organizer completed with unhandled errors: \n#{formatted_validation_errors}"
      @error_info = ErrorInfo.new(error, message: message, fatal: fatal)
    end

    def message
      error_message = <<~TEXT
        \nOrganizer: #{organizer_name}
          Action: #{action_name} failed with errors:
          Validation Errors: #{formatted_validation_errors}
      TEXT
      error_message = "#{error_message}\n#{error_info.error_summary}" if error
      error_message
    end

    private

    def formatted_validation_errors
      JSON.pretty_generate(context&.errors.presence || {})
    end

    def organizer_name
      organizer ? organizer.name.split('::').last : 'N/A'
    end

    def action_name
      action ? action.name.split('::').last : 'N/A'
    end
  end
end
