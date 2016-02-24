module Logfoo::Rack

  class Log

    IGNORED              = %w{ /health /_ping }.freeze
    HTTP_X_FORWARDED_FOR = 'HTTP_X_FORWARDED_FOR'.freeze
    REMOTE_ADDR          = 'REMOTE_ADDR'.freeze

    def initialize(app, log = nil)
      @log = log || Logfoo.get_logger(LOGGER_NAME)
      @app = app
    end

    def call(env)
      began_at = Time.now
      status, header, body = @app.call(env)
      header = R::Utils::HeaderHash.new(header)
      body   = R::BodyProxy.new(body) { log(env, status, header, began_at, body) }
      [status, header, body]
    end

    private

    def log(env, status, header, began_at, body)
      return if ignored?(status, env)

      now    = Time.now
      addr   = (env[HTTP_X_FORWARDED_FOR] || env[REMOTE_ADDR]).to_s.split(", ").first
      method = env[R::REQUEST_METHOD]
      path   = env[R::PATH_INFO]

      payload = {
        method:   method,
        path:     path,
        query:    env[R::QUERY_STRING],
        status:   status.to_s[0..3],
        len:      header[R::CONTENT_LENGTH] || 0,
        addr:     addr,
        duration: now - began_at
      }

      @log.info [method, path].join(" "), payload
    end

    def ignored?(status, env)
      status > 199 && status < 299 && IGNORED.include?(env[R::PATH_INFO])
    end

  end
end


