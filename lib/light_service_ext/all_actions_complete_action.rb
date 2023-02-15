module LightServiceExt
  class AllActionsCompleteAction < ApplicationAction
    executed do |context|
      raise_error =
        context.allow_raise_on_failure? &&
        (context.failure? || context.errors.present?)

      raise ContextError.new(ctx: context) if raise_error

      context[:outcome] = Outcome::COMPLETE
    end
  end
end
