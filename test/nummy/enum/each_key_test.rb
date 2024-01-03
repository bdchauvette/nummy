# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".each_key" do
    it "is an alias for .each_const_name" do
      # can't use our assert_aliased helper here because the methods have different
      # owners, and are therefore not equal.
      orig_method = Nummy::ConstEnumerable.instance_method(:each_const_name)
      new_method = Nummy::Enum.singleton_class.instance_method(:each_key)

      assert_equal orig_method.original_name,
                   new_method.original_name,
                   "should have same original name"

      assert_equal orig_method.source_location,
                   new_method.source_location,
                   "should have same source location"

      assert_equal orig_method.parameters,
                   new_method.parameters,
                   "should have same parameters"
    end
  end
end
