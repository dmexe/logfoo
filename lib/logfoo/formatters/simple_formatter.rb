module Logfoo ; class SimpleFormatter < LogfmtFormatter

  FORMAT           = "[%5s]: %s -%s%s".freeze
  BACKTRACE_LINE   = "\t%s\n".freeze
  EXCEPTION_LINE   = "%s: %s\n".freeze

  private

  def format_line(line)
    attrs = line.to_h
    attrs.delete(:backtrace)
    str = []
    str << "#{remove_nl format_hash(line.to_h)}\n"
    if line.is_a?(ErrLine)
      str << format_exception(line)
    end
    str.join("")
  end

  def format_exception(line)
    values = []
    values << (EXCEPTION_LINE % [line.exception.class, line.exception.message])
    if line.exception.backtrace.is_a?(Array)
      values << line.exception.backtrace.map{|l| BACKTRACE_LINE % l }.join
    end
    values.join
  end

  def format_hash(attrs)
    level   = attrs.delete(:level)
    message = attrs.delete(:msg)
    logger  = attrs.delete(:logger)

    IGNORED_KEYS.each do |f|
      attrs.delete(f)
    end

    payload = super(attrs)
    payload = payload.empty? ? "" : " [#{payload}]"
    message = message.to_s.empty? ? "" : " #{message}"
    FORMAT % [level.upcase, logger, message, payload]
  end
end ; end
