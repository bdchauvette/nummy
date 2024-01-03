# frozen_string_literal: true

require "nummy/errors"
require "nummy/version"

# Utilities that that build on Ruby's Enumerable module to provide
# functionality like enumerated types ("enums"), enumerating over constants,
# and enumerating over the members of data classes.
#
# This module does NOT provide additional methods to the Enumerable module.
module Nummy
  autoload :AutoSequenceable, "nummy/auto_sequenceable"
  autoload :ConstEnumerable, "nummy/const_enumerable"
  autoload :OrderedConstEnumerable, "nummy/ordered_const_enumerable"
  autoload :MemberEnumerable, "nummy/member_enumerable"
  autoload :Enum, "nummy/enum"

  # Alias for {Enum.define}
  def self.enum(...)
    Enum.define(...)
  end
end
