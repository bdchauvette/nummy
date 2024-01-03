# frozen_string_literal: true

require "nummy/auto_sequenceable"
require "nummy/ordered_const_enumerable"
require "nummy/errors"

module Nummy
  # An opinionated class for defining enum-like data using constants.
  #
  # There are many gems out there for defining enum-like data, including
  # +ActiveRecord::Enum+, +Ruby::Enum+, and +Dry::Types::Enum+. The defining
  # characteristic of this particular class is that it is meant to be light on
  # metaprogramming in order to make it easier for static analysis tools to work
  # with the enum fields. By basing the enums on constants, tools like Ruby LSP
  # can provide better support for things like "Go To Definition",
  # autocompletion of enum keys, and documentation for specific enum fields on
  # hover.
  #
  # The enums are built on top of {AutoSequenceable}, which provides support for
  # defining sequences of values, and {OrderedConstEnumerable} to provide support for
  #
  # This class is designed to be used as a superclass that can be inherited from
  # to create classes that define the enum fields.
  #
  # @see AutoSequenceable
  # @see OrderedConstEnumerable
  #
  # @example Compass points
  #  class CardinalDirection < Nummy::Enum
  #    NORTH = 0
  #    EAST = 90
  #    SOUTH = 180
  #    WEST = 270
  #  end
  #
  #  CompassPoint::NORTH
  #  # => 0
  #
  #  CompassPoint.values
  #  # => [0, 90, 180, 270]
  #
  #  CompassPoint.key?(:NORTH)
  #  # => true
  #
  #  CompassPoint.key?(:NORTH_NORTH_WEST)
  #  # => false
  #
  # @example Using as a guard
  #  class Status < Nummy::Enum
  #    DRAFT = :draft
  #    PUBLISHED = :published
  #    RETRACTED = :retracted
  #  end
  #
  #  def update_status(status)
  #    raise ArgumentError, "invalid status" unless Status.any?(status)
  #  end
  class Enum
    class << self
      include AutoSequenceable
      include OrderedConstEnumerable

      # Anonymous block forwarding doesn't work when the block is passed within
      # another block, which is what we do in +.enum+ below.
      #
      # rubocop:disable Naming/BlockForwarding

      # Creates a new subclass of +Nummy::Enum+ using the given name-value pairs from
      # the keyword arguments.
      #
      # @overload define(*auto_keys, **pairs)
      #  @param auto_keys [Array<Symbol>] keys that will be assigned a value using {Enum.auto}
      #  @param pairs [Hash{Symbol => Object}] keys that will be assigned the given values
      #  @return [Class<Nummy::Enum>]
      #
      # @overload define(*auto_keys, **pairs, &)
      #  @param auto_keys [Array<Symbol>] keys that will be assigned a value using {Enum.auto}
      #  @param pairs [Hash{Symbol => Object}] keys that will be assigned the given values
      #  @yield [Class<Nummy::Enum>] the new subclass
      #  @return [Class<Nummy::Enum>]
      def define(*auto_keys, **pairs, &block)
        Class.new(self) do
          auto_keys.each { |key| const_set(key, auto) }
          pairs.each { |key, value| const_set(key, value) }

          class_eval(&block) if block_given?
        end
      end
      # rubocop:enable Naming/BlockForwarding

      # Prevent inheriting from subclasses of {Enum} in order to keep the
      # constant lookup logic simple.
      #
      # Without inheritance, we only need to lookup constants on +self+. With
      # inheritance, we would have to look up constants on +self+ and all of its
      # superclasses, and we would also need to keep track of ordering.
      #
      # For the use case of enums, inheritance should not be neccessary. New
      # enums can be combined using other methods, like {#merge}.
      #
      # @private
      def inherited(subclass)
        if subclass.superclass != Enum
          raise InheritanceError, "cannot subclass enum #{display_name}"
        end

        super(subclass)
      end

      # Returns whether the value of any constant in +self+ is +==+ to +other+
      #
      # This is intended to allow the enum to be used in case expressions,
      #
      # @param [Object] other
      # @return [Boolean]
      #
      # @example Checking if a value matches a value in +self+.
      #  class Status < Nummy::Enum
      #    DRAFT = 'draft'
      #    PUBLISHED = 'published'
      #  end
      #
      #  puts Status === 'draft'
      #  # => true
      #
      #  puts Status === 'retracted'
      #  # => false
      #
      # @example Matching a value in a case expression
      #   class SuccessStatus < Nummy::Enum
      #     OK = 200
      #     CREATED = 201
      #     # ...
      #   end
      #
      #   class RedirectStatus < Nummy::Enum
      #     MULTIPLE_CHOICES = 300
      #     MOVED_PERMANENTLY = 301
      #     # ...
      #   end
      #
      #   case status
      #   when SucessStatus
      #     # ...
      #   when RedirectStatus
      #     # ...
      #   end
      def ===(other)
        each_value.any? { |value| value == other }
      end

      # @!method each_const_name
      #   Alias for {OrderedConstEnumerable#each_const_name}.
      alias each_key each_const_name

      # @!method each_const_value
      #   Alias for {OrderedConstEnumerable#each_const_value}.
      #
      #   @note
      #     This method is used as the basis for the enumeration methods provided
      #     by the +Enumerable+ module.
      alias each_value each_const_value
      alias each each_const_value

      # @!method each_const_pair
      #   Alias for {OrderedConstEnumerable#each_const_pair}.
      alias each_pair each_const_pair

      # Returns a new +Array+ containing the keys in +self+.
      #
      # The keys will be the same as the names of the own (i.e. non-inherited)
      # constants in +self+, ordered following the logic in
      # {OrderedConstEnumerable}.
      #
      # @return [Array<Symbol>]
      def keys
        # Not using each_key.to_a because each_key just calls nummy_constants
        # internally, so we can skip converting the constants to an enumerator
        # and just get the relevant constants directly.
        nummy_constants
      end

      # Returns the key of the constant in +self+ that has the given value.
      #
      # If no key has the given value, returns +nil+.
      #
      # @param target_value [Object]
      # @return [Symbol, NilClass]
      #
      # @raise [KeyError] if no key exists.
      def key(target_value)
        each_pair { |key, value| return key if value == target_value }

        # stree-ignore
        raise KeyError.new("no key found for value: #{target_value.inspect}", receiver: self)
      end

      # Returns whether +self+ has the given key.
      #
      # @param [Symbol, String] key
      # @return [Boolean]
      def key?(key)
        return false if key_scoped?(key)
        const_defined?(key, false)
      end

      # Returns the value of the constant in +self+ that has the given key.
      #
      # @raise [KeyError] if the given key is invalid or does not exist.
      def value(key)
        if key_scoped?(key)
          # stree-ignore
          raise KeyError.new("cannot use scoped enum key: #{key.inspect}", receiver: self, key:)
        end

        nummy_const_get(key)
      rescue NameError
        # Avoid attaching the NameError as the cause, because it just adds
        # unnecessary noise in the stack trace.

        # stree-ignore
        raise KeyError.new("key not found: #{key.inspect}", receiver: self, key:), cause: nil
      end

      # Allow bracketed lookup of constants by key.
      alias [] value

      # Returns whether +self+ has a constant with the given value.
      #
      # @param target_value [Object]
      # @return [Boolean]
      def value?(target_value)
        each_value.any? { |value| value == target_value }
      end

      # Returns an +Array+ containing the values of the constants in +self+.
      #
      # @return [Array<Object>]
      def values
        each_value.to_a
      end

      # Returns an +Array+ containing the values of the given keys in +self+.
      #
      # @param [Array<Symbol, String>] selected_keys
      # @return [Array<Object>]
      # @raise [KeyError] if any of the given names are invalid or do not exist.
      def values_at(*selected_keys)
        selected_keys.map! { |key| value(key) }
      end

      # Returns an +Array+ containing the key-value pairs in +self+.
      #
      # @return [Array<Array<Symbol, Object>>]
      def pairs
        each_pair.to_a
      end

      # Returns the value for the constant with the given key, with ability to
      # return default values if no constant is defined.
      #
      # @overload fetch(key)
      #   Returns the value for the constant with the given key.
      #
      #   @raise [KeyError] if no such constant exists.
      #   @return [Object]
      #
      # @overload fetch(key, default_value)
      #   Returns the value for the constant with the given key. If no such
      #   constant exists, returns the given default value.
      #
      #   @return [Object]
      #
      # @overload fetch(key, &)
      #   Returns the value for the constant with the given key. If no such
      #   constant exists, calls the given block and returns its result.
      #
      #   @yieldparam [Symbol] key
      #   @yieldreturn [Object]
      #   @return [Object]
      def fetch(key, *args)
        case args.size
        when 1
          warn "block supersedes default value argument" if block_given?
        when (2..)
          # stree-ignore
          raise ArgumentError, "wrong number of arguments (given #{args.size + 1}, expected 1..2)"
        end

        value(key)
      rescue KeyError
        if block_given?
          yield key
        elsif args.any?
          args.first
        else
          raise
        end
      end

      # Creates a new sublcass of {Enum} by merging the entries of +self+ with
      # the entries of the other enums.
      #
      # Internally, this method converts each of the arguments to hashes then
      # merges them together, so the merging of duplicate keys follows the
      # behavior of +Hash#merge+.
      def merge(*other_enums, &)
        return self if other_enums.empty?

        to_h
          .merge(*other_enums.map!(&:to_h), &)
          .each_with_object(Class.new(Enum)) do |(key, value), merged|
            merged.const_set(key, value)
          end
      end

      # Creates a new sublcass of {Enum} consisting of the entries of +self+
      # that correspond to the given keys.
      #
      # @param [Array<Symbol>] selected_keys
      # @return [Class<Enum>]
      #
      # @raise [KeyError] if any of the given keys do not exist in +self+.
      def slice(*selected_keys)
        selected_keys.each_with_object(Class.new(Enum)) do |key, sliced|
          sliced.const_set(key, self[key])
        end
      end

      # Returns whether +self+ has any pairs.
      #
      # @return [Boolean]
      def empty?
        size.zero?
      end

      # Returns the count of the constants in +self+.
      #
      # @return [Integer]
      def size
        keys.size
      end

      alias length size

      # Converts the enum to a Hash, where the constant names as keys and the
      # constant values as values.
      #
      # @return [Hash{Symbol => Object}]
      def to_h
        each_pair.to_h
      end

      # Alias to support splatting enums into keyword args.
      alias to_hash to_h

      # Returns a string representation of +self+.
      #
      # The string will contain the name-value pairs of the constants in +self+.
      #
      # @return [String]
      def inspect
        parts = [display_name]
        each_pair { |key, value| parts << "#{key}=#{value.inspect}" }

        "#<#{parts.join(" ")}>"
      end

      # Implements +PP+ support for +self+.
      def pretty_print(pp)
        pp.group(1, "#<#{display_name}", ">") do
          each_pair do |key, value|
            pp.breakable
            pp.text "#{key}="
            pp.pp value
          end
        end
      end

      private

      def display_name
        name || Nummy::Enum.name
      end

      def key_scoped?(key)
        key.to_s.include?(":")
      end
    end
  end
end
