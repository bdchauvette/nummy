# frozen_string_literal: true

module Nummy
  # Provides a method to help automatically generate sequential values.
  #
  # @see Enum
  module AutoSequenceable
    # Automatically generates values in a sequence.
    #
    # Values are calculated using a proc that is called with a succeedable
    # value, that is a value that responds to +#succ+, such as +Integer+ or
    # +String+, in order to produce the next value in the sequence.
    #
    # By default, the proc will use an integer counter that starts at zero and
    # increases by one each time +auto+ is called.
    #
    # This is similar to +iota+ in Go, or +enum.auto+ in Python.
    #
    # @see https://go.dev/wiki/Iota +iota+ in Go
    # @see https://docs.python.org/3/library/enum.html#enum.auto +enum.auto+ in Python
    #
    # @note
    #   This is not thread-safe or safe to use when reopening classes. This is
    #   only intended to be used in simple cases, such as defining a series of
    #   sequential constants.
    #
    # @overload auto
    #   Calls the stored block with the current count and returns the block result.
    #
    #   By default, returns the number of times that +auto+ has been called.
    #   However, if a block is ever given (see next override), then the value
    #   will be determined by that block.
    #
    #   @return [Object]
    #
    # @overload auto(&)
    #   Resets the counter to zero, captures and stores the given block, then
    #   calls the block and returns the block result.
    #
    #   @yieldparam value [#succ] Number of times this block has been called.
    #   @return [Object] the result of the block
    #
    # @overload auto(initial)
    #   Sets the counter value to the given value, calls the stored block with
    #   the new value, and returns the block result.
    #
    #   @param [#succ] initial The counter value to use.
    #   @return [Object]
    #
    # @overload auto(initial, &)
    #   Resets the counter, calls the given block and returns the block result.
    #
    #   @param initial [#succ] The initial counter value to use.
    #   @yieldparam value [#succ] Number of times this block has been called.
    #   @return [Object] the result of the block
    #
    # @example Generating a simple sequence of numbers.
    #   class Weekday
    #     extend Nummy::AutoSequenceable
    #
    #     SUNDAY = auto
    #     MONDAY = auto
    #     TUESDAY = auto
    #     WEDNESDAY = auto
    #     THURSDAY = auto
    #     FRIDAY = auto
    #     SATURDAY = auto
    #   end
    #
    #   Weekday::SUNDAY   # => 0
    #   Weekday::SATURDAY # => 6
    #
    # @example Using a custom block to generate a calculated sequence.
    #   module BinaryPrefix
    #     extend Nummy::AutoSequenceable
    #
    #     _  = auto { |n| 1 << 10*n } # discard first value
    #     Ki = auto
    #     Mi = auto
    #     Gi = auto
    #     Ti = auto
    #     Pi = auto
    #   end
    #
    #   BinaryPrefix::Ki == 2**10 # => true
    #   BinaryPrefix::Mi == 2**20 # => true
    #   BinaryPrefix::Gi == 2**30 # => true
    #   BinaryPrefix::Ti == 2**40 # => true
    #   BinaryPrefix::Pi == 2**50 # => true
    #
    # @example Using custom blocks and specific counters to generate multiple calculated sequences.
    #   require "bigdecimal"
    #
    #   module MetricPrefix
    #     extend Nummy::AutoSequenceable
    #
    #     DECI  = auto(1) { |n| BigDecimal(10) ** -n }
    #     CENTI = auto
    #     MILLI = auto
    #     MICRO = auto(6)
    #     NANO  = auto(9)
    #
    #     DECA = auto(1) { |n| BigDecimal(10) ** n }
    #     HECA = auto
    #     KILO = auto
    #     MEGA = auto(6)
    #     GIGA = auto(9)
    #   end
    #
    #   MetricPrefix::DECI  # => 0.1e0
    #   MetricPrefix::CENTI # => 0.1e-1
    #   MetricPrefix::MILLI # => 0.1e-2
    #   MetricPrefix::MICRO # => 0.1e-5
    #   MetricPrefix::NANO  # => 0.1e-8
    #
    #   MetricPrefix::DECA  # => 0.1e2
    #   MetricPrefix::HECA  # => 0.1e3
    #   MetricPrefix::KILO  # => 0.1e4
    #   MetricPrefix::MEGA  # => 0.1e7
    #   MetricPrefix::GIGA  # => 0.1e10
    def auto(initial = nil, &block)
      if block_given?
        self.nummy_auto_proc = block
        self.nummy_auto_value = initial || 0
      elsif initial
        self.nummy_auto_value = initial
      end

      value = nummy_auto_proc.call(nummy_auto_value)
      nummy_auto_succ!

      value
    end

    private

    attr_writer :nummy_auto_proc

    def nummy_auto_proc
      @nummy_auto_proc ||= ->(value) { value }
    end

    attr_writer :nummy_auto_value

    def nummy_auto_value
      @nummy_auto_value ||= 0
    end

    def nummy_auto_succ!
      curr_value = nummy_auto_value

      self.nummy_auto_value =
        if curr_value.respond_to?(:next)
          curr_value.next
        elsif curr_value.respond_to?(:succ)
          curr_value.succ
        else
          raise TypeError,
                "cannot increment #{curr_value.inspect}: does not respond to #next or #succ"
        end
    end
  end
end
