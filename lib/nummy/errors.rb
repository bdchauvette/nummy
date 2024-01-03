# frozen_string_literal: true

module Nummy
  # Error raised when trying to inherit from a subclass of {Enum}.
  class InheritanceError < StandardError
  end
end
