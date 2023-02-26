# frozen_string_literal: true

module LightServiceExt
  class RecordActions
    extend WithErrorHandler

    def self.call(context)
      with_error_handler(ctx: context) do
        result = yield
        return context if outcomes_complete?(ctx: context, result: result)

        merge_api_responses!(ctx: context, result: result)
      end
    end

    class << self
      def merge_api_responses!(ctx:, result:)
        invoked_action = result.invoked_action
        return if invoked_action.nil?

        ctx.add_to_successful_actions(invoked_action.name)
        ctx.add_to_api_responses(result.current_api_response)
        ctx
      end

      def outcomes_complete?(ctx:, result:)
        if result.status == Status::COMPLETE
          ctx.add_status(result.status)

          if ctx.errors.present?
            ctx.add_last_failed_context(result.to_h)
            ctx.fail!
          end
          true
        else
          false
        end
      end
    end
  end
end
