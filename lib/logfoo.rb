module Logfoo
  TRACE = 0
  DEBUG = 1
  INFO  = 2
  WARN  = 3
  ERROR = 4
  FATAL = 5

  LEVELS = ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'].freeze

  def self.get_logger(scope, context = nil)
    App.instance.start unless App.instance.started?
    Context.new(App.instance, scope.to_s, context)
  end

  def self.stop
    App.instance.stop
  end

  def self.handle_exception(*args)
    App.handle_exception(*args)
  end
end

%w{
  entry
  formatters/logfmt_formatter
  formatters/simple_formatter
  appenders/io_appender
  exception_handlers/stderr_exception_handler
  app
  context
  middlewares/err_middleware
  middlewares/log_middleware
  middlewares/hutch_error_handler
}.each do |f|
  require File.expand_path("../logfoo/#{f}", __FILE__)
end
