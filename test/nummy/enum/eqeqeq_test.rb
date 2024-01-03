# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".===" do
    it "returns true if the other value is == to any value in the group" do
      Fixtures::Enum::CardinalDirection.each_value do |value|
        assert_operator Fixtures::Enum::CardinalDirection, :===, value
      end
    end

    it "returns false if the other value is not == to any value in the group" do
      enum =
        Class.new(Nummy::Enum) do |klass|
          klass::FOO = 1
          klass::BAR = 2
          klass::BAZ = 3
        end

      refute_operator enum, :===, :flibbywobbles
    end

    it "returns false if the target value is only === to a value in the group" do
      enum =
        Class.new(Nummy::Enum) do |klass|
          klass::PATTERN = /[a-z]/
        end

      target = "a"

      assert_operator enum::PATTERN,
                      :===,
                      target,
                      "target should be === to a value in the group"

      refute_operator enum, :===, target, "group should not be === to target"
    end
  end
end
