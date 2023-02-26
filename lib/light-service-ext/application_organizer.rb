# frozen_string_literal: true

module LightServiceExt
  class ApplicationOrganizer
    extend LightService::Organizer

    class << self
      def call(context)
        with(ApplicationContext.make_with_defaults(context))
          .around_each(RecordActions)
          .reduce(all_steps)
      end

      def steps
        raise NotImplementedError
      end

      def reduce_if_success(steps)
        reduce_if(->(ctx) { ctx.success? && ctx[:errors].blank? }, steps)
      end

      private

      def all_steps
        return steps.push(AllActionsCompleteAction) if steps.is_a?(Array)

        [steps].push(AllActionsCompleteAction)
      end
    end
  end
end
