# frozen_string_literal: true

module LightServiceExt
  module Generators
    class CreateOrganizerGenerator < Base
      def generate
        path = File.join(output_root, 'services', resource, "create_#{resource}_organizer.rb")
        write_file(path, template)
      end

      private

      def template
        <<~RUBY
          # frozen_string_literal: true

          class Create#{class_name_prefix}Organizer < LightServiceExt::ApplicationOrganizer
            def self.steps
              [
                #{class_name_prefix}ValidatorAction
                # TODO: add persistence actions
              ]
            end
          end
        RUBY
      end
    end
  end
end
