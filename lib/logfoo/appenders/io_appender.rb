module Logfoo ; class IoAppender

  def initialize(out: nil, err: nil, formatter: nil)
    @stdout    = out || STDOUT
    @stderr    = err || STDERR
    @formatter = formatter || (tty? ? SimpleFormatter.new : LogfmtFormatter.new)

    sync!
  end

  def call(entry)
    io =
      case entry
      when ErrLine
        @stderr
      else
        @stdout
      end

    io.write @formatter.call(entry)
    io.flush
  end

  def tty?
    [@stdout, @stderr].inject(true) do |memo, io|
      if memo
        memo = io.respond_to?(:tty?) && io.tty?
      end
      memo
    end
  end

  def sync!
    [@stdout, @stderr].each do |io|
      if io.respond_to?(:sync=)
        io.sync = true
      end
    end
  end

end ; end
