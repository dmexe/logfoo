module Logfoo
  class HutchErrorHandler
    def handle(message_id, payload, consumer, ex)
      Logfoo::App.handle_exception(
        ex,
        "Hutch",
        payload:    payload,
        consumer:   consumer,
        message_id: message_id
      )
    end
  end
end
