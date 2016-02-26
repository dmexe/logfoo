require 'time'

module Logfoo
  class LogfmtFormatter

    UNESCAPED_STRING = /\A[\w\.\-\+\%\,\:\;\/]*\z/i.freeze
    IGNORED_KEYS     = [:time]
    FLOAT_FORMAT     = '%0.4f'.freeze

    def call(entry)
      case entry
      when ExceptionEntry, Entry
        format_entry(entry)
      else
        entry.to_s
      end
    end

    private

      def format_entry(entry)
        "#{format_hash(entry.to_h)}\n"
      end

      def format_hash(attrs)
        attrs.inject([]) do |ac, (k,v)|
          if !IGNORED_KEYS.include?(k) && !(v == nil || v == "")
            new_value = sanitize(k, v)
            ac << "#{k}=#{new_value}"
          end
          ac
        end.join(" ")
      end

      def sanitize(k, v)
        case v
        when ::Array
          if k == :backtrace
            "[" + v.map{|i| may_quote i.to_s}.join(",") + "]"
          else
            may_quote v.map{|i| i.to_s }.join(",")
          end
        when ::Integer, ::Symbol
          v.to_s
        when ::Float
          FLOAT_FORMAT % v
        when ::TrueClass
          :t
        when ::FalseClass
          :f
        when ::Time
          v.utc.iso8601
        else
          may_quote v.to_s
        end
      end

      def quote(s)
        s.inspect
      end

      def may_quote(s)
        s =~ UNESCAPED_STRING ? s : quote(s)
      end
  end
end
