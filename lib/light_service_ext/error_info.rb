# frozen_string_literal: true

module LightServiceExt
  class ErrorInfo
    attr_reader :error, :type, :message, :title, :ctx

    def initialize(error, ctx: nil, message: nil, fatal: false)
      @fatal = fatal
      @error = error
      @type = error.class.name
      @message = message || error.message
      @title = "#{error.class.name} : #{error.message}"
      @ctx = ctx
    end

    def fatal_error?
      @fatal || !non_fatal_error?
    end

    def error_summary
      header = fatal_error? ? "SERVER ERROR FOUND" : "ERROR FOUND"

      <<~TEXT
        =========== #{header}: #{title} ===========\n
        #{clean_backtrace[0, 3]&.join("\n")}
        #{'=' * 56}

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
        ctx: ctx&.to_h,
        error: exception,
        fatal_error: fatal_error?
      }
    end

    def clean_backtrace
      @clean_backtrace ||= if defined? Rails
                             Rails.backtrace_cleaner.clean(error.backtrace || [])
                           else
                             error.backtrace || []
                           end
    end

    def non_fatal_error?
      self.class.non_fatal_errors.map(&:to_s).include?(type)
    end

    class << self
      attr_writer :non_fatal_errors

      def non_fatal_errors
        @non_fatal_errors ||= []
      end
    end
  end
end
