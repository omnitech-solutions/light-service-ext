# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
module LightServiceExt
  module WithErrorHandler
    def with_error_handler(ctx:)
      @result = yield || ApplicationContext.make_with_defaults
    rescue StandardError => e
      ctx.record_raised_error(e)
      ctx.fail!
      ctx
    end
  end
end
# rubocop:enable Metrics/AbcSize
