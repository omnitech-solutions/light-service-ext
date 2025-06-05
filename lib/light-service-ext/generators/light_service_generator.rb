# frozen_string_literal: true

module LightServiceExt
  module Generators
    class LightServiceGenerator < Base
      def generate
        plugin_classes.each do |klass|
          klass.new(resource: resource, dto_class: dto_class, output_root: output_root, force: force).generate
        end
      end

      private

      def plugin_classes
        [
          DtoGenerator,
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
