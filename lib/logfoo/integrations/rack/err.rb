module Logfoo::Rack

  class Err

    TEXT_PLAIN            = 'text/plain'.freeze
    CLEAN_RE              =  /\A(rack|puma)\./.freeze

    FRAMEWORK_ERRORS      = %w{ action_dispatch.exception sinatra.error }.freeze

    INTERNAL_SERVER_ERROR = [
      500,
      {
        R::CONTENT_TYPE   => TEXT_PLAIN,
        R::CONTENT_LENGTH => Rack::Utils::HTTP_STATUS_CODES[500].bytesize
      },
      [Rack::Utils::HTTP_STATUS_CODES[500]],
    ].freeze


    def initialize(app, log = nil)
      @log = log || Logfoo.get_logger(LOGGER_NAME)
      @app = app
    end

    def call(env)
      response = @app.call(env)

      if framework_error = FRAMEWORK_ERRORS.find { |k| env[k] }
        @log.error(framework_error, clean_env(env))
      end

      response
    rescue Exception => e
      @log.error(e, clean_env(env))
      INTERNAL_SERVER_ERROR
    end

    private

    def clean_env(env)
      env.inject({}) do |ac, (key, value) |
        case
        when key =~ CLEAN_RE
          ac
        else
          ac.merge!(key => value)
        end
      end
    end

  end
end


