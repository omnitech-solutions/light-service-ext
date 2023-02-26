# frozen_string_literal: true

module LightServiceExt
  class ErrorInfo
    attr_reader :error, :type, :message, :title

    def initialize(error, message: nil, fatal: false)
      @fatal = fatal
      @error = error
      @type = error.class.name
      @message = message || error&.message
      @title = "#{error.class.name} : #{error&.message}"
    end

    def fatal_error?
      @fatal || !non_fatal_error?
    end

    def error_summary
      header = fatal_error? ? "SERVER ERROR FOUND" : "ERROR FOUND"

      <<~TEXT
        =========== #{header}: #{title} ===========

        FULL STACK TRACE
        #{clean_backtrace.join("\n")}

        #{'=' * 56}
      TEXT
    end

    def errors
      model = error && (error.try(:model) || error.try(:record))
      return model.errors.messages if model.present?

      { base: message }
    end

    def to_h
      {
        type: type,
        message: message,
        exception: title,
        backtrace: clean_backtrace[0, 3]&.join("\n"),
        error: error,
        fatal_error?: fatal_error?,
        errors: errors
      }
    end

    def backtrace
      error&.backtrace || []
    end

    def clean_backtrace
      @clean_backtrace ||= if defined? Rails.backtrace_cleaner
                             Rails.backtrace_cleaner.clean(backtrace || [])
                           else
                             backtrace || []
                           end
    end

    def non_fatal_error?
      error.nil? || LightServiceExt.config.non_fatal_error?(error)
    end
  end
end
