# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".inherited" do
    it "raises an error if a sub class is subclassed" do
      error =
        assert_raises(Nummy::InheritanceError) do
          Class.new(Fixtures::Enum::CardinalDirection)
        end

      assert_equal "cannot subclass enum Fixtures::Enum::CardinalDirection",
                   error.message
    end
  end
end
