module Logfoo ; module Rack ; class Err

  TEXT_PLAIN            = 'text/plain'.freeze
  CLEAN_RE              =  /\A(rack|puma|grape)\./.freeze

  FRAMEWORK_ERRORS      = %w{ action_dispatch.exception sinatra.error }.freeze

  INTERNAL_SERVER_ERROR = [
    500,
    {
      R::CONTENT_TYPE   => TEXT_PLAIN,
      R::CONTENT_LENGTH => R::Utils::HTTP_STATUS_CODES[500].bytesize
    },
    [R::Utils::HTTP_STATUS_CODES[500]],
  ].freeze

  def initialize(app, log = nil)
    @app = app
  end

  def call(env)
    response = @app.call(env)

    if framework_error = FRAMEWORK_ERRORS.find { |k| env[k] }
      append(framework_error, env)
    end

    response
  rescue Exception => e
    append(e, env)
    INTERNAL_SERVER_ERROR
  end

  private

  def append(e, env)
    env   = clean_env(env)
    env   = prefix_env(env)
    line  = Logfoo::ErrLine.build(
      logger_name: LOGGER_NAME,
      exception:   e,
      payload:     env
    )
    Logfoo::App.instance.append(line)
  end

  def prefix_env(env)
    env.inject({}) do |ac, (key, value)|
      ac.merge!("env.#{key}" => value)
      ac
    end
  end

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

end ; end ; end


