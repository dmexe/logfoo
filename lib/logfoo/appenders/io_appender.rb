module Logfoo
  class IoAppender
    def initialize(io = nil, formatter = nil)
      @io        = io || STDOUT
      is_tty     = @io.respond_to?(:tty?) && @io.tty?
      @formatter = formatter || (is_tty ? SimpleFormatter.new : LogfmtFormatter.new)
    end

    def call(entry)
      @io.write @formatter.call(entry)
      @io.flush
    end
  end
end
