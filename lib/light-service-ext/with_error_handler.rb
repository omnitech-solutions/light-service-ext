# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module LightServiceExt
  module WithErrorHandler
    def with_error_handler(ctx:)
      @result = yield || ApplicationContext.make_with_defaults
    rescue Rails::ActiveRecordError => e
      error_info = ErrorInfo.new(e, fatal: false)
      ctx.add_internal_only(error_info: error_info)
      ctx.add_errors(**error_info.errors)

      LightServiceExt.config.logger.error(error_info.error_summary)

      ctx.fail!
      ctx
    rescue StandardError => e
      error_info = ErrorInfo.new(e, fatal: false)
      LightServiceExt.config.logger.error(error_info.error_summary)

      raise
    end
  end
end
# rubocop:enable Metrics/AbcSize
