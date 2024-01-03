# frozen_string_literal: true

module Nummy
  # A mixin that makes a class +Enumerable+ using its +members+ method.
  #
  # This can be used for things like iterating over the members of a +Data+
  # class without having to write the boilerplate code to do so.
  #
  # This aims to implement small set of methods, modeled after +Struct+, rather
  # than a more fully-featured set of methods like +Hash+.
  module MemberEnumerable
    include Enumerable

    # Iterates through the values of the members in +self+.
    #
    # The order of the pairs is the same as the order of the array returned by
    # calling +members+.
    #
    # @overload each(&)
    #   Calls the given block with the value of each member in +self+.
    #
    #   @yieldparam [Object] value
    #   @return [self]
    #
    # @overload each
    #   Returns an +Enumerator+ that calls the given block with the value of
    #   each member in +self+.
    #
    #   @return [Enumerator<Object>]
    def each(&)
      return enum_for unless block_given?

      members.each { |member| yield send(member) }
      self
    end

    # Iterates through the name-value pairs of the members in +self+.
    #
    # The order of the pairs is the same as the order of the array returned by
    # calling +members+.
    #
    # @overload each_pair(&)
    #   Calls the given block with a two-item array containing the name and
    #   value of each member in +self+.
    #
    #   @yieldparam [Symbol] name
    #   @yieldparam [Object] value
    #   @return [self]
    #
    # @overload each_pair
    #   Returns an +Enumerator+ that iterates over with a two-item array
    #   containing the name and value of each member in +self+.
    #   @return [Enumerator<Array<Symbol, Object>>]
    def each_pair
      return enum_for(__method__) unless block_given?

      members.each { |member| yield member, send(member) }
      self
    end

    # Returns an +Array+ containing the values in +self+.
    #
    # @return [Array<Object>]
    def values
      deconstruct
    end

    # Returns an +Array+ containing the values of the given members in +self+.
    #
    # @param [Array<Symbol, String>] selected_members
    # @return [Array<Object>]
    #
    # @raise [NoMethodError] if any of the given members are invalid or do not exist.
    def values_at(*selected_members)
      selected_members.map! { |member| send(member) }
    end

    # Returns the count of members in +self+.
    #
    # @return [Integer]
    def size
      members.size
    end

    alias length size
  end
end
