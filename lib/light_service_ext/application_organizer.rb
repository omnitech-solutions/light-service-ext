module LightServiceExt
  class ApplicationOrganizer
    extend LightService::Organizer

    def self.call(context)
      with(ApplicationContext.make_with_defaults(context)).reduce(steps)
    end

    def self.steps
      raise NotImplementedError
    end
  end
end
