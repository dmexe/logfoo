module Logfoo
  Entry = Struct.new(:level, :time, :logger_name, :message, :payload, :thread) do
    def to_h
      {
        level:   level   || :info,
        time:    time    || Time.now,
        msg:     message,
        logger:  logger_name,
      }.merge!(
        payload || {}
      ).merge!(
        thread:  thread
      )
    end
  end

  ExceptionEntry = Struct.new(:level, :time, :logger_name, :exception, :payload, :thread) do
    class << self
      def build(logger_name, ex, payload = nil, options = {})
        self.new(
          options[:level],
          Time.now,
          logger_name,
          ex,
          payload,
          Thread.current.object_id
        )
      end
    end

    def to_h
      {
        level:  level || :error,
        time:   time  || Time.now,
        msg:    exception.message,
        logger: logger_name,
        err:    exception.class.to_s,
      }.merge!(
        payload || {}
      ).merge!(
        thread:     thread,
        stacktrace: exception.backtrace,
      )
    end
  end
end
