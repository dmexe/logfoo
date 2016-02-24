class TestIO < Array
  def write(value)
    self.push value
  end

  def flush ; end
end

class TestIO ; class << self
  attr_accessor :stdout, :stderr, :app

  def start
    self.stdout = TestIO.new
    self.stderr = TestIO.new

    Logfoo::App.appenders(
      Logfoo::IoAppender.new(self.stdout)
    )
    Logfoo::App.exception_handlers(
      Logfoo::StderrExceptionHanlder.new(
        Logfoo::IoAppender.new(self.stderr)
      )
    )

    self.app = Logfoo::App.instance
    self.app.start
  end

  def stop
    self.app.stop
    Logfoo::App._reset!

    self.stdout = nil
    self.stderr = nil
    self.app    = nil
  end
end ; end

module TestIOHelper
  def self.included(base)
    base.before do
      TestIO.start
    end

    base.after do
      TestIO.stop
    end
  end

  def log_app ;    TestIO.app ;    end
  def log_stdout ; TestIO.stdout ; end
  def log_stderr ; TestIO.stderr ; end
end
