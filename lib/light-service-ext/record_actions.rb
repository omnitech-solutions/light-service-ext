# frozen_string_literal: true

module LightServiceExt
  class RecordActions
    extend WithErrorHandler

    def self.call(context)
      with_error_handler(ctx: context) do
        result = yield || context
        return context if outcomes_complete?(ctx: context, result: result)

        invoked_action = result.invoked_action
        return context if invoked_action.nil?

        context.add_to_successful_actions(invoked_action.name)

        merge_api_responses!(ctx: context, result: result)
        context
      end
    end

    class << self
      def merge_api_responses!(ctx:, result:)
        api_response = result.current_api_response
        return if api_response.blank?

        ctx.add_to_api_responses(api_response)
        nil
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
