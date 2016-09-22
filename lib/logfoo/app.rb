require 'thread'
require 'singleton'

module Logfoo
  class App

    include Singleton

    IGNORE_ME_ERROR = RuntimeError.new("ignore me")

    def initialize
      @queue  = Queue.new
      @lock   = Mutex.new
      @thread = nil

      start
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

    def append(line)
      @queue.push(line) if @thread
    end

    private

      def main_loop ; Thread.new do
        begin
          loop do
            line = @queue.pop
            case line
            when :shutdown
              break
            when :boom
              raise IGNORE_ME_ERROR
            when ErrLine
              App._handle_exception(line)
            else
              App._append(line)
            end
          end
        rescue Exception => ex
          line = ErrLine.build(logger_name: self.class, exception: ex)
          App._handle_exception(line)
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

    def _handle_exception(entry)
      @@exception_handlers.each{|fn| fn.call(entry) }
    end

    def _append(entry)
      @@appenders.each{|fn| fn.call(entry) }
    end

    def _reset!
      appenders IoAppender.new
      exception_handlers StderrExceptionHanlder.new
    end
  end ; end

  App._reset!
end
