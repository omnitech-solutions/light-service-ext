# frozen_string_literal: true

module LightServiceExt
  module Generators
    class DtoGenerator < Base
      def generate
        path = File.join(output_root, 'services', "#{resource}_dto.rb")
        write_file(path, template)
      end

      private

      def template
        <<~RUBY
          # frozen_string_literal: true

          class #{class_name_prefix}DTO < LightServiceExt::ApplicationContract
            params do
              # TODO: define params
            end
          end
        RUBY
      end
    end
  end
end
