require 'hutch'

module Logfoo ; module Hutch ; class ErrorHandler
  attr_reader :bunny_log, :hutch_log

  class << self
    attr_accessor :handler
  end

  ID = 'Hutch'.freeze

  def initialize
    @hutch_log = Logfoo.get_logger(ID)
    @bunny_log = Logfoo.get_logger('Bunny')
    @bunny_log.level = Logfoo::WARN
  end

  def handle(message_id, payload, consumer, ex)
    line = ErrLine.build(
      logger_name: ID,
      exception:   ex,
      payload:     (payload || {}).merge!(
        consumer:    consumer,
        message_id:  message_id
      )
    )
    App.instance.append(line)
  end
end ; end ; end

Logfoo::Hutch::ErrorHandler.handler = Logfoo::Hutch::ErrorHandler.new

Hutch::Logging.logger = Logfoo::Hutch::ErrorHandler.handler.hutch_log
Hutch::Config.set(:error_handlers, [Logfoo::Hutch::ErrorHandler.handler])
Hutch::Config.set(:client_logger,   Logfoo::Hutch::ErrorHandler.handler.bunny_log)
