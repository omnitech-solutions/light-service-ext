# frozen_string_literal: true

module LightServiceExt
  class ApplicationContract < Dry::Validation::Contract
    register_macro(:email) do
      key.failure('must be a valid email') unless Regex.match?(:email, value)
    end
  end
end
