module Logfoo ; Timed = Struct.new(:source) do
  def benchmark(level, message, payload, block)
    payload    ||= {}
    time_start   = Time.now.to_f
    reply        = source._call_log_fn(block, payload)

    payload.merge!(duration: Time.now.to_f - time_start)
    source.public_send(level, message, payload)
    reply
  end

  Logfoo::LEVELS.each do |lv|
    level_id = lv.downcase.to_sym

    define_method level_id do |message, payload = nil, &block|
      benchmark(level_id, message, payload || {}, block)
    end
  end
end ; end
