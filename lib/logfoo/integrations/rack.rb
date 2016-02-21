require 'rack'

module Logfoo ; module Rack
  R = ::Rack
  LOGGER_NAME = 'Rack'.freeze
end ; end

require File.expand_path("../rack/err", __FILE__)
require File.expand_path("../rack/log", __FILE__)
