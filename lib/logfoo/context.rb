module Logfoo ; class Context

  attr_reader :level, :name, :thread_id, :timed

  THREAD_CONTEXT = :"logfoo_context"

  def initialize(app, name, context = nil)
    @app     = app
    @name    = name
    @level   = Logfoo::DEBUG
    @context = context || {}
    @timed   = Timed.new(self)
  end

  def level=(level)
    @level = level.to_i
  end

  def []=(k,v)
    if v == nil
      @context.delete(k)
    else
      @context[k] = v
    end
  end

  def context(keys = nil)
    if block_given?
      keys ||= {}
      begin
        Thread.current[THREAD_CONTEXT] ||= []
        Thread.current[THREAD_CONTEXT].push(keys)
        yield
      ensure
        Thread.current[THREAD_CONTEXT].pop
        if Thread.current[THREAD_CONTEXT] == []
          Thread.current[THREAD_CONTEXT] = nil
        end
      end
    else
      keys = (Thread.current[THREAD_CONTEXT] || []).inject({}) do |memo, kvs|
        kvs.each do |(k,v)|
          memo.merge!(k => v)
        end
        memo
      end
      @context.merge(keys)
    end
  end

  def add(level, message, progname, &block)
    lv = Logfoo::LEVELS[level]
    if lv
      public_send(lv.downcase, message, &block)
    end
  end

  Logfoo::LEVELS.each_with_index do |lv, idx|
    define_method :"#{lv.downcase}?" do
      idx >= level
    end
  end

  Logfoo::LEVELS.each_with_index do |lv, idx|
    level_id = lv.downcase.to_sym

    define_method level_id do |message = nil, payload = nil, &block|
      if idx >= level
        payload = context.merge(payload || {})
        message = block ? _call_log_fn(block, payload) : message
        line    = build_line(level_id, message, payload)
        @app.append(line)
      end
    end
  end

  def _call_log_fn(fn, payload)
    case fn.arity
    when 0
      fn.call
    when 1
      fn.call(payload)
    else
      raise RuntimeError, "invalid lambda arity, must be 0 or 1, was #{fn.arity}"
    end
  end

  private

  def build_line(level_id, message, payload)
    if message.is_a?(Exception)
      ErrLine.build(
        logger_name: @name,
        exception:   message,
        payload:     payload,
        level:       level_id
      )
    else
      LogLine.build(
        logger_name: @name,
        message:     message,
        payload:     payload,
        level:       level_id
      )
    end
  end

end ; end
