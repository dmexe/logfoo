module Logfoo
  TRACE = 0
  DEBUG = 1
  INFO  = 2
  WARN  = 3
  ERROR = 4
  FATAL = 5

  LEVELS = ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'].freeze

  extend self

  def get_logger(scope, context = nil)
    App.instance.start unless App.instance.started?
    Context.new(App.instance, scope.to_s, context)
  end

  def stop
    App.instance.stop
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
}.each do |f|
  require File.expand_path("../logfoo/#{f}", __FILE__)
end

at_exit { Logfoo.stop }
