# frozen_string_literal: true

module LightServiceExt
  class RecordActions
    extend WithErrorHandler

    def self.call(context)
      with_error_handler(ctx: context) do
        self.before_execute_block.call(context)

        result = yield || context

        self.after_execute_block.call(context)
        self.after_success_block.call(context) if result.success?
        self.after_failure_block.call(context) if result.failure?

        return context if outcomes_complete?(ctx: context, result: result)
        merge_api_responses!(ctx: context, result: result)
      end
    end

    class << self
      attr_writer :before_execute_block, :after_execute_block, :after_success_block, :after_failure_block

      def before_execute_block
        @before_execute_block ||= ->(_context) {}
      end

      def after_execute_block
        @after_execute_block ||= ->(_context) {}
      end

      def after_success_block
        @after_success_block ||= ->(_context) {}
      end

      def after_failure_block
        @after_failure_block ||= ->(_context) {}
      end
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
