# frozen_string_literal: true

module LightServiceExt
  class ApplicationAction
    extend LightService::Action

    def self.inherited(base)
      base.singleton_class.prepend AroundActionExecuteExtension
      super
    end
  end
end
