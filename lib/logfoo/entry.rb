module Logfoo
  Entry = Struct.new(:level, :time, :scope, :message, :payload, :thread) do
    def to_h
      {
        level:   level   || :info,
        time:    time    || Time.now,
        message: message,
        scope:   scope,
        thread:  thread,
      }.merge!(payload || {})
    end
  end

  ExceptionEntry = Struct.new(:level, :time, :scope, :exception, :payload, :thread) do
    def to_h
      {
        level:     level || :error,
        time:      time  || Time.now,
        message:   exception.message,
        scope:     scope,
        exception: exception.class.to_s,
        thread:    thread,
      }.merge!(payload || {})
    end
  end
end
