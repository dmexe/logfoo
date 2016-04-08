require 'test_helper'

describe Logfoo::Context do

  include TestIOHelper

  it "should handle levels" do
    log = Logfoo.get_logger(self.class)
    log.level = Logfoo::DEBUG
    expect(log.trace?).must_equal false
    expect(log.debug?).must_equal true
    expect(log.info?).must_equal true
    log.level = Logfoo::INFO
    expect(log.trace?).must_equal false
    expect(log.debug?).must_equal false
    expect(log.info?).must_equal true
  end

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
    assert_match(/logger=Logfoo::Context/, log_stdout[0])
    assert_match(/thread=#{tid}/,          log_stdout[0])

    assert_match(/level=debug/,            log_stdout[1])
    assert_match(/msg=\"debug 1\"/,        log_stdout[1])
    assert_match(/logger=Logfoo::Context/, log_stdout[1])
    assert_match(/thread=#{tid}/,          log_stdout[1])

    assert_match(/level=warn/,             log_stdout[2])
    assert_match(/msg=\"warn 1\"/,         log_stdout[2])
    assert_match(/logger=Logfoo::Context/, log_stdout[2])
    assert_match(/thread=#{tid}/,          log_stdout[2])
  end

  it "should merge contexts" do
    log = Logfoo.get_logger(self.class)
    log.info  "message", foo: :bar

    log = Logfoo.get_logger(self.class, foo: :bar)
    log.context key: :value do
      log.info  "first", foo: :overwrite
      log.context key2: :value2, key3: :value3 do
        log.info  "second"
        log.context key2: :replaced do
          log.info "third"
        end
        log.info  "secondout"
      end
      log.info "firstout", foo: :overwrite
    end
    log.info "end"

    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 7, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,             log_stdout[0])
    assert_match(/msg=message/,            log_stdout[0])
    assert_match(/logger=Logfoo::Context/, log_stdout[0])
    assert_match(/foo=bar/,                log_stdout[0])
    assert_match(/thread=#{tid}/,          log_stdout[0])

    assert_match(/level=info/,             log_stdout[1])
    assert_match(/msg=first/ ,             log_stdout[1])
    assert_match(/logger=Logfoo::Context/, log_stdout[1])
    assert_match(/key=value/,              log_stdout[1])
    assert_match(/thread=#{tid}/,          log_stdout[1])

    assert_match(/level=info/,             log_stdout[2])
    assert_match(/msg=second/ ,            log_stdout[2])
    assert_match(/logger=Logfoo::Context/, log_stdout[2])
    assert_match(/key=value/,              log_stdout[2])
    assert_match(/key2=value2/,            log_stdout[2])
    assert_match(/key3=value3/,            log_stdout[2])

    assert_match(/level=info/,             log_stdout[3])
    assert_match(/msg=third/ ,             log_stdout[3])
    assert_match(/logger=Logfoo::Context/, log_stdout[3])
    assert_match(/key=value/,              log_stdout[3])
    assert_match(/key2=replaced/,          log_stdout[3])
    assert_match(/key3=value3/,            log_stdout[3])

    assert_match(/level=info/,             log_stdout[4])
    assert_match(/msg=secondout/ ,         log_stdout[4])
    assert_match(/logger=Logfoo::Context/, log_stdout[4])
    assert_match(/key=value/,              log_stdout[4])
    assert_match(/key2=value2/,            log_stdout[4])
    assert_match(/key3=value3/,            log_stdout[4])

    assert_match(/level=info/,             log_stdout[5])
    assert_match(/msg=firstout/ ,          log_stdout[5])
    assert_match(/logger=Logfoo::Context/, log_stdout[5])
    assert_match(/key=value/,              log_stdout[5])

    assert_match(/level=info/,             log_stdout[6])
    assert_match(/msg=end/,                log_stdout[6])
    assert_match(/logger=Logfoo::Context/, log_stdout[6])
    assert_match(/foo=bar/,                log_stdout[6])
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
    assert_match(/err=RuntimeError/,       log_stderr[0])
    assert_match(/thread=#{tid}/,          log_stderr[0])

    assert_match(/level=error/,            log_stderr[1])
    assert_match(/msg=boom/,               log_stderr[1])
    assert_match(/err=RuntimeError/,       log_stderr[1])
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

  it "should write by add method" do
    log = Logfoo.get_logger(self.class)
    log.add(2, "message")
    log.add(3, nil) { "block" }
    Logfoo.stop

    assert_match(/level=info/,     log_stdout[0])
    assert_match(/msg=message/,    log_stdout[0])

    assert_match(/level=warn/,     log_stdout[1])
    assert_match(/msg=block/,      log_stdout[1])
  end
end
