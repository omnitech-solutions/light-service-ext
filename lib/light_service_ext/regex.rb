module LightServiceExt
  module Regex
    TYPE = {
      :email => URI::MailTo::EMAIL_REGEXP
    }.freeze

    class << self
      def match?(type, value)
        TYPE[type].match?(value)
      end
    end
  end
end
