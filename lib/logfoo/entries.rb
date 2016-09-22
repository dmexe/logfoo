module Logfoo
  LogLine = Struct.new(:level, :time, :logger_name, :message, :payload, :thread) do
    class << self
      def build(logger_name:, message:, payload: nil, level: nil)
        self.new(
          level || :info,
          Time.now.utc,
          logger_name,
          message,
          payload || {},
          Thread.current.object_id
        )
      end
    end

    def to_h
      {
        level:   level,
        time:    time,
        msg:     message,
        logger:  logger_name,
      }.merge!(
        payload
      ).merge!(
        thread:  thread
      )
    end
  end

  ErrLine = Struct.new(:level, :time, :logger_name, :exception, :payload, :thread) do
    class << self
      def build(logger_name:, exception:, payload: nil, level: nil)
        self.new(
          level || :error,
          Time.now.utc,
          logger_name,
          exception,
          payload || {},
          Thread.current.object_id
        )
      end
    end

    def to_h
      {
        level:  level,
        time:   time,
        msg:    exception.message,
        logger: logger_name,
        err:    exception.class.to_s,
      }.merge!(
        payload
      ).merge!(
        thread:     thread,
        stacktrace: exception.backtrace,
      )
    end
  end
end
