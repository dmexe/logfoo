require 'time'

module Logfoo
  class LogfmtFormatter

    UNESCAPED_STRING = /\A[\w\.\-\+\%\,\:\;\/]*\z/i.freeze
    STACKTRACE_RE    = /^(.+?):(\d+):in `(.+)'$/.freeze
    IGNORED_KEYS     = [:time]
    FLOAT_FORMAT     = '%0.4f'.freeze

    def call(entry)
      case entry
      when ExceptionEntry, Entry
        format_entry(entry)
      else
        "#{remove_nl entry.to_s}\n"
      end
    end

    private

      def remove_nl(s)
        s.tr("\n", ' ')
      end

      def format_entry(entry)
        "#{remove_nl format_hash(entry.to_h)}\n"
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

      def format_stacktrace(stack)
        stack =
          stack.inject([]) do |ac, line|
            if line.match(STACKTRACE_RE)
              ac.push "[#{$1}:#{$2}:#{$3}]"
            end
            ac
          end
        if stack.any?
          "\"#{stack.join("")}\""
        end
      end

      def sanitize(k, v)
        case v
        when ::Array
          if k == :stacktrace
            format_stacktrace(v)
            #quote v.map{|i| i.to_s }.join(",")
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
