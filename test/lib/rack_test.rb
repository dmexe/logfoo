require 'rack/test'
require 'test_helper'

describe "Rack" do

  include TestIOHelper
  include Rack::Test::Methods

  class << self
    attr_accessor :is_error
  end

  def app
    _this = self
    Rack::Builder.new do
      use Logfoo::Rack::Log
      use Logfoo::Rack::Err
      run lambda { |env|
        if _this.class.is_error
          raise 'boom'
        else
          [200, {}, "body"]
        end
      }
    end
  end

  it "should log requests" do
    self.class.is_error = false
    get '/'
    log_app.stop
    expect(last_response.body).must_equal 'body'
    expect(log_stdout.join("\n")).must_include "level=info msg=\"GET /\" logger=Rack method=GET path=/ status=200 len=0 addr=127.0.0.1"
    expect(log_stderr).must_be_empty
  end

  it "should log exceptions" do
    self.class.is_error = true
    get '/'
    log_app.stop
    expect(last_response.body).must_equal "Internal Server Error"
    expect(log_stdout.join("\n")).must_include "level=info msg=\"GET /\" logger=Rack method=GET path=/ status=500 len=21 addr=127.0.0.1"
    expect(log_stderr.join("\n")).must_include "level=error msg=boom logger=Rack err=RuntimeError env.REQUEST_METHOD=GET"
  end
end
