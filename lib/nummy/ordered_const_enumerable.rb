# frozen_string_literal: true

require "nummy/const_enumerable"

module Nummy
  # A module that can be extended in order to enumerate over constants
  # in a +Hash+-like manner. This can be used to build enum-like classes and
  # modules that work nicely with static analysis.
  #
  # The enumeration order for methods defined by this module is guaranteed to be
  # stable across calls and methods, and in _most_ cases will match the order in
  # which the constants were defined.
  #
  # The only exception is for constants that are defined *before* extending
  # {ConstEnumerable}. Those constants are sorted in stable way, but the order
  # will not necessarily match insertion order. This is because those constants
  # are looked up using +Module#constants+ when this module is extended, and
  # that method does not have any ordering guarantees. Instead, these constants
  # are sorted using +Symbol#<=>+.
  #
  # @note
  #  If stable ordering is not important, consider using {ConstEnumerable},
  #  which is more performant but does not guarantee ordering.
  #
  # @see ConstEnumerable
  # @see Enum
  module OrderedConstEnumerable
    include ConstEnumerable

    # @!method each_const_name(...)
    #   Same as {ConstEnumerable#each_const_name}, but with stable ordering.

    # @!method each_const_value(...)
    #   Same as {ConstEnumerable#each_const_value}, but with stable ordering.

    # @!method each_const_pair(...)
    #   Same as {ConstEnumerable#each_const_pair}, but with stable ordering.

    # @private
    def self.extended(mod)
      # Sort own constants lexicographically to ensure a stable order, because
      # +Module#constants+ does not have its own ordering guarantees.
      sorted_constants = mod.send(:constants, false).sort!

      sorted_constants.each do |name|
        mod.send(:nummy_record_const_insertion_order, name)
      end
    end

    # Hook used to track the order in which constants are added to the group.
    #
    # We do this because +Module#constants+ does not guarantee the order that
    # constants will be returned in.
    #
    # @note
    #   This hook was added in Ruby 3.2.
    #
    # @private
    def const_added(name)
      super(name)
      nummy_record_const_insertion_order(name)
    end

    private

    def nummy_constants
      nummy_const_insertion_orders.keys & constants(false)
    end

    def nummy_const_insertion_orders
      # using a Hash to get the deduplication benefits of a Set while also
      # preserving the insertion order. We only care about the keys, so the
      # values will all be ignored.
      @nummy_const_insertion_orders ||= {}
    end

    def nummy_record_const_insertion_order(name)
      nummy_const_insertion_orders[name] = nil
    end
  end
end
