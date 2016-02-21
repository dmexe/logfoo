require 'hutch'

module Logfoo ; module Hutch
  class ErrorHandler
    ID = 'Hutch'.freeze

    def handle(message_id, payload, consumer, ex)
      Logfoo._handle_exception(
        ex,
        ID,
        payload:    payload,
        consumer:   consumer,
        message_id: message_id
      )
    end
  end
end ; end

::Hutch::Config.set(:error_handlers, [Logfoo::Hutch::ErrorHandler.new])
