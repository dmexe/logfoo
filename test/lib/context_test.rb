require 'test_helper'

describe Logfoo::Context do

  class TestIO < Array
    def write(value)
      self.push value
    end

    def flush ; end
  end

  before do
    @test_stdout = TestIO.new
    @test_stderr = TestIO.new

    Logfoo::App.appenders(
      Logfoo::IoAppender.new(@test_stdout)
    )
    Logfoo::App.exception_handlers(
      Logfoo::StderrExceptionHanlder.new(
        Logfoo::IoAppender.new(@test_stderr)
      )
    )
  end

  after do
    Logfoo::App.instance.stop
    Logfoo::App.reset!
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

    assert_equal 3, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,             @test_stdout[0])
    assert_match(/message=\"info 1\"/,     @test_stdout[0])
    assert_match(/scope=Logfoo::Context/,  @test_stdout[0])
    assert_match(/thread=#{tid}/,          @test_stdout[0])

    assert_match(/level=debug/,            @test_stdout[1])
    assert_match(/message=\"debug 1\"/,    @test_stdout[1])
    assert_match(/scope=Logfoo::Context/,  @test_stdout[1])
    assert_match(/thread=#{tid}/,          @test_stdout[1])

    assert_match(/level=warn/,             @test_stdout[2])
    assert_match(/message=\"warn 1\"/,     @test_stdout[2])
    assert_match(/scope=Logfoo::Context/,  @test_stdout[2])
    assert_match(/thread=#{tid}/,          @test_stdout[2])
  end

  it "should merge contexts" do
    log = Logfoo.get_logger(self.class)
    log.info  "message", foo: :bar

    log = Logfoo.get_logger(self.class, foo: :bar)
    log.info  "message", foo: :overwrite, key: :value

    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 2, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,             @test_stdout[0])
    assert_match(/message=message/,        @test_stdout[0])
    assert_match(/scope=Logfoo::Context/,  @test_stdout[0])
    assert_match(/foo=bar/,                @test_stdout[0])
    assert_match(/thread=#{tid}/,          @test_stdout[0])

    assert_match(/level=info/,             @test_stdout[1])
    assert_match(/message=message/,        @test_stdout[1])
    assert_match(/scope=Logfoo::Context/,  @test_stdout[1])
    assert_match(/foo=overwrite/,          @test_stdout[1])
    assert_match(/key=value/,              @test_stdout[1])
    assert_match(/thread=#{tid}/,          @test_stdout[1])
  end

  it "should handle block" do
    log = Logfoo.get_logger(self.class)
    log.info{ "block message" }
    log.info("message", foo: :bar) { "block message 2" }
    Logfoo.stop

    assert_equal 2, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,                      @test_stdout[0])
    assert_match(/message=\"block message\"/,       @test_stdout[0])

    assert_match(/level=info/,                      @test_stdout[1])
    assert_match(/message=\"block message 2\"/,     @test_stdout[1])
    assert_match(/foo=bar/,                         @test_stdout[1])
  end

  it "should handle exceptions" do
    ex = RuntimeError.new("boom")
    log = Logfoo.get_logger(self.class)
    log.info(ex)
    log.error(ex, key: :value)
    Logfoo.stop

    tid = Thread.current.object_id

    assert_equal 2, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,              @test_stdout[0])
    assert_match(/message=boom/,            @test_stdout[0])
    assert_match(/exception=RuntimeError/,  @test_stdout[0])
    assert_match(/thread=#{tid}/,           @test_stdout[0])

    assert_match(/level=error/,             @test_stdout[1])
    assert_match(/message=boom/,            @test_stdout[1])
    assert_match(/exception=RuntimeError/,  @test_stdout[1])
    assert_match(/key=value/,               @test_stdout[1])
    assert_match(/thread=#{tid}/,           @test_stdout[1])
  end

  it "should measure block" do
    log = Logfoo.get_logger(self.class)
    log.measure("message") { sleep 0.1 }
    Logfoo.stop

    assert_equal 1, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,                      @test_stdout[0])
    assert_match(/message=message/,                 @test_stdout[0])
    assert_match(/duration=0\.10/,                  @test_stdout[0])
  end
end
