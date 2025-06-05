# frozen_string_literal: true

module LightServiceExt
  module Generators
    class ValidatorActionGenerator < Base
      def generate
        path = File.join(output_root, 'services', resource, "#{resource}_validator_action.rb")
        write_file(path, template)
      end

      private

      def template
        <<~RUBY
          # frozen_string_literal: true

          class #{class_name_prefix}ValidatorAction < LightServiceExt::ApplicationValidatorAction
            self.contract_class = #{dto_class.name}
          end
        RUBY
      end
    end
  end
end
