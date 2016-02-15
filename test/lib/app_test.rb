require 'test_helper'

describe Logfoo::App do

  class TestIO < Array
    def puts(value)
      self.push value
    end
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

    @app = Logfoo::App.instance
    @app.start
  end

  after do
    @app.stop
    Logfoo::App.reset!
  end

  it "should write messages using low level api" do
    entry = Logfoo::Entry.new(
      :info,
      Time.now,
      self.class.to_s,
      "boom!",
      { foo: "bar", baz: [1,2,3], key: true }
    )
    @app.append(entry)
    @app.stop

    assert_equal 1, @test_stdout.size
    assert_empty @test_stderr

    assert_match(/level=info/,                  @test_stdout.join("\n"))
    assert_match(/message=\"boom!\"/,           @test_stdout.join("\n"))
    assert_match(/scope=Logfoo::App /, @test_stdout.join("\n"))
    assert_match(/foo=bar/,                     @test_stdout.join("\n"))
    assert_match(/baz=1,2,3/,                   @test_stdout.join("\n"))
    assert_match(/key=t/,                       @test_stdout.join("\n"))
  end

  it "should write exception using low level api" do
    err = Struct.new(:message, :backtrace).new("boom!", ["backtrace line"])
    entry = Logfoo::ExceptionEntry.new(
      :error,
      Time.now,
      self.class.to_s,
      err,
      { foo: "bar" }
    )
    @app.append(entry)
    @app.stop

    assert_empty @test_stderr
    assert_equal 2, @test_stdout.size

    assert_match(/level=error/,                 @test_stdout.join("\n"))
    assert_match(/message=\"boom!\"/,           @test_stdout.join("\n"))
    assert_match(/exception=\"#<Class/,         @test_stdout.join("\n"))
    assert_match(/scope=Logfoo::App /, @test_stdout.join("\n"))
    assert_match(/foo=bar/,                     @test_stdout.join("\n"))
  end

  it "should handle low level errors" do
    @app.append(:boom)
    @app.stop

    assert_empty @test_stdout
    assert_equal 2, @test_stderr.size

    assert_match(/level=error/,                 @test_stderr.join("\n"))
    assert_match(/message=\"ignore me"/,        @test_stderr.join("\n"))
    assert_match(/exception=RuntimeError/,      @test_stderr.join("\n"))
    assert_match(/scope=Logfoo::App/,  @test_stderr.join("\n"))
    assert_match(/RuntimeError: ignore me\n/,   @test_stderr.join("\n"))
    assert_match(/`block in main_loop'\z/,      @test_stderr.join("\n"))
  end
end
