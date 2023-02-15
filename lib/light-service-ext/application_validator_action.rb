# frozen_string_literal: true

module LightServiceExt
  class ApplicationValidatorAction < ApplicationAction
    expects :input
    promises :params, :errors

    executed do |context|
      validator = map_and_validate_inputs(context)
      add_params(context, **validator.to_h)
      add_errors(context, **validator.errors.to_h.transform_values(&:first))
    end

    class << self
      def inherited(base)
        super
        base.extend ClassMethods
      end

      private

      # Fetches params mapper & contract from the action that was actually invoked
      # then validates against these and returns the contract results
      def map_and_validate_inputs(context)
        invoked_action = context[:invoked_action]

        mapped_params = invoked_action.params_mapper_class.map_from(context)
        invoked_action.contract_class.new.call(mapped_params)
      end
    end

    class NullContract < ApplicationContract
      params { {} }
    end

    NullMapper =
      Struct.new(:ctx) do
        def self.map_from(context)
          context[:input]
        end
      end

    module ClassMethods
      attr_writer :contract_class, :params_mapper_class

      def contract_class
        @contract_class ||= NullContract
      end

      def params_mapper_class
        @params_mapper_class ||= NullMapper
      end
    end
  end
end
