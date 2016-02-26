module Logfoo
  class IoAppender
    def initialize(io = nil, formatter = nil)
      @io        = io || STDOUT

      if @io.respond_to?(:sync=)
        @io.sync = true
      end

      is_tty     = @io.respond_to?(:tty?) && @io.tty?
      @formatter = formatter || (is_tty ? SimpleFormatter.new : LogfmtFormatter.new)
    end

    def call(entry)
      write @formatter.call(entry)
    end

    def write(body)
      @io.write body
      @io.flush
    end
  end
end
