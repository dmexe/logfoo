require 'thread'
require 'singleton'

module Logfoo
  class App

    include Singleton

    IGNORE_ME_ERROR = RuntimeError.new("ignore me")

    def initialize
      @queue = Queue.new
      @lock  = Mutex.new
    end

    def start
      @lock.synchronize do
        unless @thread
          @thread = main_loop
        end
      end
    end

    def started?
      !!@thread
    end

    def stop
      @lock.synchronize do
        return unless @thread
        append(:shutdown)
        @thread.join
        @thread = nil
      end
    end

    def append(entry)
      @queue.push(entry) if @thread
    end

    private

      def main_loop ; Thread.new do
        begin
          loop do
            entry = @queue.pop
            if entry == :shutdown
              break
            end
            if entry == :boom
              raise IGNORE_ME_ERROR
            end
            App._append(entry)
          end
        rescue Exception => ex
          App._handle_exception(ex, self.class)
          retry
        end
      end ; end
  end

  class App ; class << self
    @@appenders          = []
    @@exception_handlers = []

    def appenders(*fn)
      @@appenders = fn.flatten
    end

    def exception_handlers(*fn)
      @@exception_handlers = fn.flatten
    end

    def _handle_exception(ex, scope = nil, context = {})
      @@exception_handlers.each{|fn| fn.call(ex, scope, context) }
    end

    def _append(entry)
      @@appenders.each{|fn| fn.call(entry) }
    end

    def _reset!
      @@appenders          = [IoAppender.new]
      @@exception_handlers = [StderrExceptionHanlder.new]
    end
  end ; end

  App._reset!
end
