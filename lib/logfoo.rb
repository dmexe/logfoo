module Logfoo
  TRACE = 0
  DEBUG = 1
  INFO  = 2
  WARN  = 3
  ERROR = 4
  FATAL = 5

  LEVELS = ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'].freeze

  autoload :Rack, File.expand_path("../logfoo/integrations/rack", __FILE__)

  extend self

  def get_logger(scope, context = nil)
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
