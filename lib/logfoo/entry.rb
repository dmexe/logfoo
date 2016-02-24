module Logfoo
  Entry = Struct.new(:level, :time, :scope, :message, :payload, :thread) do
    def to_h
      {
        level:   level   || :info,
        time:    time    || Time.now,
        msg:     message,
        scope:   scope,
      }.merge!(
        payload || {}
      ).merge!(
        thread:  thread
      )
    end
  end

  ExceptionEntry = Struct.new(:level, :time, :scope, :exception, :payload, :thread) do
    class << self
      def build(scope, ex, payload = nil, options = {})
        self.new(
          options[:level],
          Time.now,
          scope,
          ex,
          payload,
          Thread.current.object_id
        )
      end
    end

    def to_h
      {
        level:     level || :error,
        time:      time  || Time.now,
        msg:       exception.message,
        scope:     scope,
        err:       exception.class.to_s,
      }.merge!(
        payload || {}
      ).merge!(
        thread:  thread
      )
    end
  end
end
