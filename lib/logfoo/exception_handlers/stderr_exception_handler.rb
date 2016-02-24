module Logfoo

  class StderrExceptionHanlder
    BACKTRACE_LINE   = "\t%s\n".freeze
    EXCEPTION_LINE   = "%s: %s\n".freeze

    def initialize(appender = nil)
      @appender = appender || IoAppender.new(STDERR)
    end

    def call(entry)
      @appender.write format(entry)
    end

    def format(entry)
      values = []
      values << (EXCEPTION_LINE % [entry.exception.class, entry.exception.message])
      if entry.exception.backtrace.is_a?(Array)
        values << entry.exception.backtrace.map{|l| BACKTRACE_LINE % l }.join
      end
      values.join
    end
  end

end
