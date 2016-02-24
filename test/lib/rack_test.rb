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
    expect(log_stdout.join("\n")).must_include "level=info msg=\"GET /\" scope=Rack method=GET path=/ status=200 reslen=4 reqlen=0 addr=127.0.0.1"
    expect(log_stderr).must_be_empty
  end

  it "should log exceptions" do
    self.class.is_error = true
    get '/'
    log_app.stop
    expect(last_response.body).must_equal "Internal Server Error"
    expect(log_stdout.join("\n")).must_include "level=info msg=\"GET /\" scope=Rack method=GET path=/ status=500 reslen=21 reqlen=0 addr=127.0.0.1"
    expect(log_stdout.join("\n")).must_include "level=error msg=boom scope=Rack err=RuntimeError REQUEST_METHOD=GET"
    expect(log_stderr).must_be_empty
  end
end
