module Logfoo
  class SimpleFormatter < LogfmtFormatter

    FORMAT = "[%5s]: %s -%s%s".freeze

    private

      def format_hash(attrs)
        level   = attrs.delete(:level)
        message = attrs.delete(:msg)
        scope   = attrs.delete(:scope)

        IGNORED_KEYS.each do |f|
          attrs.delete(f)
        end

        payload = super(attrs)
        payload = payload.empty? ? "" : " [#{payload}]"
        message = message.to_s.empty? ? "" : " #{message}"
        FORMAT % [level.upcase, scope, message, payload]
      end
  end
end
