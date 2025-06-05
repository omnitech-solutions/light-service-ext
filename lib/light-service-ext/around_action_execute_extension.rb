# frozen_string_literal: true

module LightServiceExt
  module AroundActionExecuteExtension
    def execute(context)
      return context if context.status == Status::COMPLETE

      before_execute_block.call(context)

      result = super(context.merge(invoked_action: self))

      context.merge!(result)
      context.fail! if result.errors.present?

      after_execute_block.call(context)
      after_success_block.call(context) if result.success?
      after_failure_block.call(context) if result.failure?
      result
    end
  end
end
