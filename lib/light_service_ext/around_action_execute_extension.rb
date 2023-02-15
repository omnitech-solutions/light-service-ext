module LightServiceExt
  module AroundActionExecuteExtension
    def execute(context)
      result = super(context.merge(invoked_action: self))

      context.merge!(result)
      context.fail! if result.errors.present?
      result
    end
  end
end
