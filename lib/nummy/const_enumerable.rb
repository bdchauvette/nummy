# frozen_string_literal: true

module Nummy
  # A module that can be extended in order to enumerate over constants
  # in a +Hash+-like manner. This can be used to build enum-like classes and
  # modules that work nicely with static analysis.
  #
  # The enumeration order for methods defined by this module is *not* guaranteed to be stable
  # across calls and methods. This is because those constants are
  # looked up using +Module#constants+, and that method does not have any
  # ordering guarantees.
  #
  # @note
  #  If stable ordering is important, you should use {OrderedConstEnumerable}.
  #
  # @see OrderedConstEnumerable
  module ConstEnumerable
    include Enumerable

    # Iterates through the names of the constants in +self+.
    #
    # @overload each_const_name(&)
    #   Calls the given block with the name of each constant in +self+.
    #
    #   @yieldparam [Symbol] name
    #   @return [self]
    #
    # @overload each_const_name
    #   Returns an +Enumerator+ that calls the given block with the name of each
    #   constant in +self+.
    #
    #   @return [Enumerator<Symbol>]
    def each_const_name(&)
      return enum_for(__method__) unless block_given?

      nummy_constants.each(&)
      self
    end

    # Iterates through the values of the constants in +self+.
    #
    # @overload each_const_value(&)
    #   Calls the given block with the value of each constant in +self+.
    #
    #   The order of the values is guaranteed to be the same as the insertion
    #   order of the constants.
    #
    #   @yieldparam [Object] value
    #   @return [self]
    #
    # @overload each_const_value
    #   Returns an +Enumerator+ that calls the given block with the value of
    #   each constant in +self+.
    #
    #   @return [Enumerator<Object>]
    def each_const_value
      return enum_for(__method__) unless block_given?

      each_const_name { |name| yield nummy_const_get(name) }
      self
    end

    # Iterates through the name-value pairs of the constants in +self+.
    #
    # @note
    #   This method is used as the basis for the enumeration methods provided
    #   by the +Enumerable+ module.
    #
    # @overload each_const_pair(&)
    #   Calls the given block with a two-item array containing the name and
    #   value of each constant in +self+.
    #
    #   The order of the pairs is guaranteed to be the same as the insertion
    #   order of the constants.
    #
    #   @yieldparam [Symbol] name
    #   @yieldparam [Object] value
    #   @return [self]
    #
    # @overload each_const_pair
    #   Returns an +Enumerator+ that iterates over with a two-item array
    #   containing the name and value of each constant in +self+.
    #   @return [Enumerator<Array<Symbol, Object>>]
    def each_const_pair
      return enum_for(__method__) unless block_given?

      each_const_name { |name| yield name, nummy_const_get(name) }
      self
    end

    # Use {each_const_pair} as the base for enumeration methods in +Enumerable+.
    alias each each_const_pair

    private

    def nummy_const_get(name) = const_get(name, false)

    def nummy_constants = constants(false)
  end
end
