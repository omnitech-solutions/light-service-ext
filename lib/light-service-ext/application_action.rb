# frozen_string_literal: true

module LightServiceExt
  class ApplicationAction
    extend LightService::Action

    def self.inherited(base)
      base.extend LifecycleMethods
      base.singleton_class.prepend AroundActionExecuteExtension
      super
    end

    module LifecycleMethods
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
    end
  end
end
