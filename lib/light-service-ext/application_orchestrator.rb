module LightServiceExt
  class ApplicationOrchestrator < ApplicationOrganizer
    class << self
      def call(context, &)
        orchestrator_ctx = process_each_organizer(ApplicationContext.make_with_defaults(context),
                                                  &)
        with(orchestrator_ctx).around_each(RecordActions).reduce(all_steps)
      end

      def organizer_steps
        raise NotImplementedError
      end

      def process_each_organizer(orchestrator_ctx, &each_organizer_result)
        organizer_steps.each do |step_class|
          exec_method = exec_method_for(step_class)
          current_organizer_ctx = step_class.send(exec_method, orchestrator_ctx.input)
          yield(current_organizer_ctx, orchestrator_ctx: orchestrator_ctx) if each_organizer_result
        end
        orchestrator_ctx
      end

      private

      def exec_method_for(klass)
        return :call if klass.is_a?(LightService::Organizer) || klass.is_a?(Proc)

        :execute
      end
    end
  end
end
