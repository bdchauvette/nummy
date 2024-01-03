# frozen_string_literal: true

module Minitest
  module Assertions
    def assert_aliased(mod, orig_sym, as:)
      new_sym = as

      assert mod.instance_method(new_sym),
             "should have instance method #{new_sym.inspect}"

      assert_equal mod.instance_method(orig_sym),
                   mod.instance_method(new_sym),
                   "should alias #{orig_sym.inspect} as #{new_sym.inspect}"
    end

    def assert_equal_items(expected, actual)
      assert_equal expected.size, actual.size, "should have same size"
      assert_empty expected - actual, "should have all expected items"
      assert_empty actual - expected, "should not have any extra items"
    end
  end
end
