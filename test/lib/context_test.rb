require 'test_helper'

describe Logfoo::Context do

  include TestIOHelper

  it "should write messages" do
    log = Logfoo.get_logger(self.class)
    log.info  "info 1"
    log.debug "debug 1"

    log.level = Logfoo::WARN
    log.info "info 2"
    log.warn "warn 1"

    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 3, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,             log_stdout[0])
    assert_match(/msg=\"info 1\"/,         log_stdout[0])
    assert_match(/scope=Logfoo::Context/,  log_stdout[0])
    assert_match(/thread=#{tid}/,          log_stdout[0])

    assert_match(/level=debug/,            log_stdout[1])
    assert_match(/msg=\"debug 1\"/,        log_stdout[1])
    assert_match(/scope=Logfoo::Context/,  log_stdout[1])
    assert_match(/thread=#{tid}/,          log_stdout[1])

    assert_match(/level=warn/,             log_stdout[2])
    assert_match(/msg=\"warn 1\"/,         log_stdout[2])
    assert_match(/scope=Logfoo::Context/,  log_stdout[2])
    assert_match(/thread=#{tid}/,          log_stdout[2])
  end

  it "should merge contexts" do
    log = Logfoo.get_logger(self.class)
    log.info  "message", foo: :bar

    log = Logfoo.get_logger(self.class, foo: :bar)
    log.info  "message", foo: :overwrite, key: :value

    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 2, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,             log_stdout[0])
    assert_match(/msg=message/,            log_stdout[0])
    assert_match(/scope=Logfoo::Context/,  log_stdout[0])
    assert_match(/foo=bar/,                log_stdout[0])
    assert_match(/thread=#{tid}/,          log_stdout[0])

    assert_match(/level=info/,             log_stdout[1])
    assert_match(/msg=message/,            log_stdout[1])
    assert_match(/scope=Logfoo::Context/,  log_stdout[1])
    assert_match(/foo=overwrite/,          log_stdout[1])
    assert_match(/key=value/,              log_stdout[1])
    assert_match(/thread=#{tid}/,          log_stdout[1])
  end

  it "should handle block" do
    log = Logfoo.get_logger(self.class)
    log.info{ "block message" }
    log.info("message", foo: :bar) { "block message 2" }
    Logfoo.stop

    assert_equal 2, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,              log_stdout[0])
    assert_match(/msg=\"block message\"/,   log_stdout[0])

    assert_match(/level=info/,              log_stdout[1])
    assert_match(/msg=\"block message 2\"/, log_stdout[1])
    assert_match(/foo=bar/,                 log_stdout[1])
  end

  it "should handle exceptions" do
    ex = RuntimeError.new("boom")
    log = Logfoo.get_logger(self.class)
    log.info(ex)
    log.error(ex, key: :value)
    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 0, log_stdout.size
    assert_equal 2, log_stderr.size

    assert_match(/level=info/,             log_stderr[0])
    assert_match(/msg=boom/,               log_stderr[0])
    assert_match(/exception=RuntimeError/, log_stderr[0])
    assert_match(/thread=#{tid}/,          log_stderr[0])

    assert_match(/level=error/,            log_stderr[1])
    assert_match(/msg=boom/,               log_stderr[1])
    assert_match(/exception=RuntimeError/, log_stderr[1])
    assert_match(/key=value/,              log_stderr[1])
    assert_match(/thread=#{tid}/,          log_stderr[1])
  end

  it "should measure block" do
    log = Logfoo.get_logger(self.class)
    log.measure("message") { sleep 0.1 }
    Logfoo.stop

    assert_equal 1, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,     log_stdout[0])
    assert_match(/msg=message/,    log_stdout[0])
    assert_match(/duration=0\.10/, log_stdout[0])
  end
end
