# frozen_string_literal: true

module LightServiceExt
  module AroundActionExecuteExtension
    def execute(context)
      return context if context.status == Status::COMPLETE
      self.before_execute_block.call(context)

      result = super(context.merge(invoked_action: self))

      context.merge!(result)
      context.fail! if result.errors.present?

      self.after_execute_block.call(context)
      self.after_success_block.call(context) if result.success?
      self.after_failure_block.call(context) if result.failure?
      result
    end
  end
end
