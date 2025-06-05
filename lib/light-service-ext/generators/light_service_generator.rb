# frozen_string_literal: true

module LightServiceExt
  module Generators
    class LightServiceGenerator < Base
      def generate
        plugin_classes.each do |klass|
          klass.new(resource: resource, attributes: attributes, output_root: output_root, force: force).generate
        end
      end

      private

      def plugin_classes
        [
          ContractGenerator,
          ValidatorActionGenerator,
          CreateOrganizerGenerator,
          UpdateOrganizerGenerator,
          FetchOrganizerGenerator,
          ListOrganizerGenerator,
          DestroyOrganizerGenerator
        ]
      end
    end
  end
end
