require 'time'

module Logfoo
  class LogfmtFormatter

    UNESCAPED_STRING = /\A[\w\.\-\+\%\,\:\;\/]*\z/i.freeze
    IGNORED_KEYS     = [:time]
    FLOAT_FORMAT     = '%0.4f'.freeze
    BACKTRACE_LINE   = "\t%s\n".freeze
    EXCEPTION_LINE   = "%s: %s".freeze

    def call(entry)
      case entry
      when ExceptionEntry
        format_exception(entry)
      when Entry
        format_entry(entry)
      else
        entry.to_s
      end
    end

    private

      def format_entry(entry)
        "#{format_hash(entry.to_h)}\n"
      end

      def format_exception(entry)
        values = [format_hash(entry.to_h)]
        if entry.exception && entry.exception.backtrace.is_a?(Array)
          values << (EXCEPTION_LINE % [entry.exception.class, entry.exception.message])
          values << entry.exception.backtrace.map{|l| BACKTRACE_LINE % l }.join
        end
        values.join("\n")
      end

      def format_hash(attrs)
        attrs.inject([]) do |ac, (k,v)|
          if !IGNORED_KEYS.include?(k) && !(v == nil || v == "")
            new_value = sanitize(v)
            ac << "#{k}=#{new_value}"
          end
          ac
        end.join(" ")
      end

      def sanitize(v)
        case v
        when ::Array
          may_quote v.map{|i| i.to_s}.join(",")
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
