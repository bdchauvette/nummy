# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".values_at" do
    describe "when all of the given keys exist" do
      it "returns the values for the given keys of the enum" do
        subject = Fixtures::Enum::CardinalDirection

        assert_equal [0, 180], subject.values_at(:NORTH, :SOUTH)
      end

      it "returns the values in the order of the given keys" do
        subject = Fixtures::Enum::CardinalDirection
        pairs = subject.pairs

        (1..pairs.size).each do |n|
          pairs.permutation(n) do |permutation|
            keys = permutation.map(&:first)
            values = permutation.map(&:last)

            assert_equal values, subject.values_at(*keys)
          end
        end
      end
    end

    describe "when no keys are given" do
      it "returns an empty array" do
        subject = Fixtures::Enum::CardinalDirection

        assert_empty subject.values_at
      end
    end

    describe "when an unknown key is given" do
      it "raises a KeyError" do
        subject = Fixtures::Enum::Empty

        error = assert_raises(KeyError) { subject.values_at(:foo) }
        assert_equal "key not found: :foo", error.message
        assert_equal :foo, error.key, "should set the error key"
        assert_equal subject, error.receiver, "should set the error receiver"
      end
    end
  end
end
