# frozen_string_literal: true

module LightServiceExt
  class ApplicationAction
    extend LightService::Action

    class << self
      def add_params(ctx, **params)
        add_to_context(ctx, :params, **params)
      end

      def add_errors(ctx, **errors)
        add_to_context(ctx, :errors, **errors)

        ctx.fail_and_return! if ctx[:errors].present?
      end

      private

      def add_to_context(ctx, key, **args)
        return if ctx.nil?

        ctx[key].merge!(args.dup)
        nil
      end
    end

    def self.inherited(base)
      base.singleton_class.prepend AroundActionExecuteExtension
      super
    end
  end
end
