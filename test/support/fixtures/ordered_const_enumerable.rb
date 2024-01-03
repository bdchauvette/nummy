# frozen_string_literal: true

require "nummy/ordered_const_enumerable"

module Fixtures
  module OrderedConstEnumerable
    module Empty
      extend Nummy::OrderedConstEnumerable
    end

    module CardinalDirection
      extend Nummy::OrderedConstEnumerable

      NORTH = 0
      EAST = 90
      SOUTH = 180
      WEST = 270
    end

    module Inherited
      extend Nummy::OrderedConstEnumerable

      include(Module.new { |mod| mod::INHERITED = :inherited })

      FOO = :foo
      BAR = :bar
      BAZ = :baz
    end
  end
end
