module Logfoo
  module Mixin
    def self.included(base)
      base.extend ClassMethods
      base.log = Logfoo.get_logger(base.name)
    end

    module ClassMethods
      attr_accessor :log
    end

    def log
      self.class.log
    end
  end
end
