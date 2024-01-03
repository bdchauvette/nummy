# frozen_string_literal: true

require "nummy/enum"

module Fixtures
  module Enum
    class Empty < Nummy::Enum
    end

    class CardinalDirection < Nummy::Enum
      NORTH = 0
      EAST = 90
      SOUTH = 180
      WEST = 270
    end

    class Inherited < Nummy::Enum
      include(Module.new { |mod| mod::INHERITED = :inherited })

      FOO = :foo
      BAR = :bar
      BAZ = :baz
    end
  end
end
