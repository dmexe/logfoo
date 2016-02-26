require 'test_helper'

class MixinTestClass
  include Logfoo.mixin
end

describe Logfoo::Mixin do
  it "log method should be defined" do
    expect(MixinTestClass.log).must_be_instance_of Logfoo::Context
    expect(MixinTestClass.new.log).must_be_instance_of Logfoo::Context

    expect(MixinTestClass.log.scope).must_equal 'MixinTestClass'
  end
end
