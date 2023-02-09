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

    def to_h
      {
        type: type,
        message: message,
        exception: title,
        backtrace: clean_backtrace[0, 3]&.join("\n"),
        error: error,
        fatal_error?: fatal_error?
      }
    end

    def backtrace
      error&.backtrace || []
    end

    def clean_backtrace
      @clean_backtrace ||= if defined? Rails
                             Rails.backtrace_cleaner.clean(backtrace || [])
                           else
                             backtrace || []
                           end
    end

    def non_fatal_error?
      error.nil? || self.class.non_fatal_errors.map(&:to_s).include?(type)
    end

    class << self
      attr_writer :non_fatal_errors

      def non_fatal_errors
        @non_fatal_errors ||= []
      end
    end
  end
end
