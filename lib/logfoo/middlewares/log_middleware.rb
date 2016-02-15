require 'rack'

module Logfoo

  class LogMiddleware
    FORMAT  = %{%s "%s %s%s %s" %d %s %0.4f}
    IGNORED = %w{ /health /_ping }

    def initialize(app, log = nil)
      @log = log || Logfoo.get_logger('Rack')
      @app = app
    end

    def call(env)
      began_at = Time.now
      status, header, body = @app.call(env)
      header = Rack::Utils::HeaderHash.new(header)
      body   = Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
      [status, header, body]
    end

    private

    def log(env, status, header, began_at)
      return if ignored?(status, env)

      now    = Time.now
      length = extract_content_length(header)
      peer   = env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"]

      payload = {
        method:   env[Rack::REQUEST_METHOD],
        path:     env[Rack::PATH_INFO],
        query:    env[Rack::QUERY_STRING],
        status:   status.to_s[0..3],
        len:      length,
        peer:     peer,
        duration: now - began_at
      }

      @log.info "request", payload
    end

    def extract_content_length(headers)
      headers[Rack::CONTENT_LENGTH] || 0
    end

    def ignored?(status, env)
      status > 199 && status < 299 && IGNORED.include?(env[Rack::PATH_INFO])
    end
  end
end


