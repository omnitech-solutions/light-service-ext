# frozen_string_literal: true

module LightServiceExt
  module WithErrorHandler
    def with_error_handler(ctx:)
      @result = yield || ctx
    rescue StandardError => e
      ctx.record_raised_error(e)
      ctx.add_status(Status::COMPLETE)
      ctx.fail!
      ctx
    end
  end
end
