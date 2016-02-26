require 'test_helper'

describe Logfoo::App do

  include TestIOHelper

  it "should write messages using low level api" do
    entry = Logfoo::Entry.new(
      :info,
      Time.now,
      self.class.to_s,
      "boom!",
      { foo: "bar", baz: [1,2,3], key: true }
    )
    log_app.append(entry)
    log_app.stop

    assert_equal 1, log_stdout.size
    assert_empty log_stderr

    assert_match(/level=info/,                  log_stdout.join(""))
    assert_match(/msg=\"boom!\"/,               log_stdout.join(""))
    assert_match(/scope=Logfoo::App /,          log_stdout.join(""))
    assert_match(/foo=bar/,                     log_stdout.join(""))
    assert_match(/baz=1,2,3/,                   log_stdout.join(""))
    assert_match(/key=t/,                       log_stdout.join(""))
  end

  it "should write exception using low level api" do
    err   = Struct.new(:message, :backtrace).new("boom!", ["backtrace line"])
    entry = Logfoo::ExceptionEntry.new(
      :error,
      Time.now,
      self.class.to_s,
      err,
      { foo: "bar" }
    )
    log_app.append(entry)
    log_app.stop

    assert_equal 1, log_stderr.size
    assert_equal 0, log_stdout.size

    assert_match(/level=error/,                 log_stderr.join(""))
    assert_match(/msg=\"boom!\"/,               log_stderr.join(""))
    assert_match(/exception=\"#<Class/,         log_stderr.join(""))
    assert_match(/scope=Logfoo::App /,          log_stderr.join(""))
    assert_match(/foo=bar/,                     log_stderr.join(""))
    assert_match(/backtrace line/,              log_stderr.join(""))
  end

  it "should handle low level errors" do
    log_app.append(:boom)
    log_app.stop

    assert_empty log_stdout
    assert_equal 1, log_stderr.size

    assert_match("level=error msg=\"ignore me\"", log_stderr.join(""))
    assert_match("scope=Logfoo::App",             log_stderr.join(""))
    assert_match("exception=RuntimeError",        log_stderr.join(""))
    assert_match("backtrace=[",                   log_stderr.join(""))
    assert_match("block in main_loop",            log_stderr.join(""))
  end
end

