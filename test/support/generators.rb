# frozen_string_literal: true

module PropCheck
  module Generators
    module_function

    # Generates symbols that can be used as names of constants.
    def const_name
      simple_symbol
        .where { |sym| !sym.empty? && !sym.start_with?("_") }
        .map(&:upcase)
    end

    # Generates arrays of unique symbols that can be used as names of constants.
    def const_name_array(**)
      array(const_name, uniq: true, min: 6, **)
    end
  end
end

# Alias +PropCheck::Generators+ for better ergonomics.
G = PropCheck::Generators
