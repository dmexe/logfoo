module Logfoo ; class StderrExceptionHanlder
  def initialize(appender = nil)
    @appender = appender || IoAppender.new(STDERR)
  end

  def call(entry)
    @appender.call entry
  end
end ; end
