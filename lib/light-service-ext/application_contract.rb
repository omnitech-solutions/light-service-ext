# frozen_string_literal: true

module LightServiceExt
  class ApplicationContract < Dry::Validation::Contract
    register_macro(:email) do
      key.failure('must be a valid email') unless Regex.match?(:email, value)
    end

    module InstanceMethods
      unless respond_to?(:keys)
        def keys
          return [] if schema.nil?

          schema&.rules&.keys || []
        end
      end

      unless respond_to?(:t)
        def t(key, base_path: "errors", **opts)
          self.class.t(key, base_path: base_path, **opts)
        end
      end
    end

    module ClassMethods
      unless respond_to?(:keys)
        def keys
          return [] if schema.nil?

          schema&.rules&.keys || []
        end
      end

      unless respond_to?(:t)
        def t(key, base_path: "errors", **opts)
          scope = opts[:scope] || ""
          path = [base_path, scope, key.to_s].join(".")

          message = messages.translate(path)
          return message if message.exclude?("%{")

          (message % opts.except(:scope))
        end
      end
    end

    def self.inherited(base)
      super
      base.include InstanceMethods
      base.extend ClassMethods
    end
  end
end
