# frozen_string_literal: true

module LightServiceExt
  module Generators
    # Generates a basic dry-validation contract for the resource
    class ContractGenerator < Base
      def generate
        path = File.join(output_root, 'services', "#{resource}_contract.rb")
        write_file(path, template)
      end

      private

      def template
        attr_lines = attributes.map do |attr|
          "        required(:#{attr}).filled(:string)"
        end.join("\n")

        <<~RUBY
          # frozen_string_literal: true

          class #{class_name_prefix}Contract < LightServiceExt::ApplicationContract
            params do
#{attr_lines}
            end
          end
        RUBY
      end
    end
  end
end
