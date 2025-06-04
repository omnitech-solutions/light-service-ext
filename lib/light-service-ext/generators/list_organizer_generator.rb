# frozen_string_literal: true

module LightServiceExt
  module Generators
    class ListOrganizerGenerator < Base
      def generate
        path = File.join(output_root, 'services', resource, "list_#{resource_plural}_organizer.rb")
        write_file(path, template)
      end

      private

      def template
        <<~RUBY
          # frozen_string_literal: true

          class List#{class_name_prefix.pluralize}Organizer < LightServiceExt::ApplicationOrganizer
            def self.steps
              [
                #{class_name_prefix}ValidatorAction
                # TODO: add listing actions
              ]
            end
          end
        RUBY
      end
    end
  end
end
