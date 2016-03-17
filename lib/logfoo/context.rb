module Logfoo
  class Context

    attr_reader :level, :scope, :thread_id

    def initialize(app, scope, context = nil)
      @app          = app
      @scope        = scope
      @thread_id    = :"logfoo_context_#{scope}"
      @level        = Logfoo::DEBUG
      @context      = context || {}
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
          Thread.current[thread_id] ||= []
          Thread.current[thread_id].push(keys)
          yield
        ensure
          Thread.current[thread_id].pop
          if Thread.current[thread_id] == []
            Thread.current[thread_id] = nil
          end
        end
      else
        keys = (Thread.current[thread_id] || []).inject({}) do |memo, kvs|
          kvs.each do |(k,v)|
            memo.merge!(k => v)
          end
          memo
        end
        @context.merge(keys)
      end
    end

    def measure(message, payload = {})
      tm = Time.now.to_f
      re = nil
      re = yield if block_given?
      tm = Time.now.to_f - tm
      payload[:duration] = tm
      self.info message, payload
      re
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
          message = block ? block.call : message
          payload = context.merge(payload || {})

          entry =
            if message.is_a?(Exception)
              ExceptionEntry.build(@scope, message, payload, level: level_id)
            else
              Entry.new(
                level_id,
                Time.now,
                @scope,
                message,
                payload,
                Thread.current.object_id
              )
            end
          @app.append(entry)
        end
      end
    end
  end
end
