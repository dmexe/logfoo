module Logfoo::Rack

  class Err

    INTERNAL_SERVER_ERROR = "Internal Server Error\n".freeze
    TEXT_PLAIN            = 'text/plain'.freeze
    CLEAN_RE              =  /\A(rack|puma)\./.freeze

    def initialize(app, log = nil)
      @log = log || Logfoo.get_logger(LOGGER_NAME)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      @log.error(e, clean_env(env))
      [
        500,
        {
          R::CONTENT_TYPE   => TEXT_PLAIN,
          R::CONTENT_LENGTH => INTERNAL_SERVER_ERROR.size
        },
        [INTERNAL_SERVER_ERROR],
      ]
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


