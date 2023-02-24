# frozen_string_literal: true

module LightServiceExt
  class ApplicationOrganizer
    extend LightService::Organizer

    def self.call(context)
      with(ApplicationContext.make_with_defaults(context))
        .around_each(RecordActions)
        .reduce(all_steps)
    end

    def self.steps
      raise NotImplementedError
    end

    def self.all_steps
      return steps.push(AllActionsCompleteAction) if steps.is_a?(Array)

      [steps].push(AllActionsCompleteAction)
    end
  end
end
