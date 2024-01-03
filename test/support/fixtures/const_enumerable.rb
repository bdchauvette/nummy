# frozen_string_literal: true

require "nummy/const_enumerable"

module Fixtures
  module ConstEnumerable
    module Empty
      extend Nummy::ConstEnumerable
    end

    module CardinalDirection
      extend Nummy::ConstEnumerable

      NORTH = 0
      EAST = 90
      SOUTH = 180
      WEST = 270
    end

    module Inherited
      extend Nummy::ConstEnumerable

      include(Module.new { |mod| mod::INHERITED = :inherited })

      FOO = :foo
      BAR = :bar
      BAZ = :baz
    end
  end
end
