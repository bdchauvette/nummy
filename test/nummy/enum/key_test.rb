# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".key" do
    describe "when there is one key with the value" do
      it "returns the name of the constant with the given value" do
        subject = Fixtures::Enum::CardinalDirection

        assert_equal :NORTH, subject.key(subject::NORTH)
        assert_equal :EAST, subject.key(subject::EAST)
        assert_equal :SOUTH, subject.key(subject::SOUTH)
        assert_equal :WEST, subject.key(subject::WEST)
      end
    end

    describe "when there are multiple keys in the enum with the value" do
      it "returns the first matching key in enumeration order" do
        subject = Fixtures::Enum::CardinalDirection

        (1..subject.pairs.size).each do |n|
          subject
            .pairs
            .permutation(n) do |permutation|
              expected_key, first_value = permutation.first

              assert_equal expected_key,
                           subject.key(first_value),
                           "should return the first constant with the given value"
            end
        end
      end
    end

    describe "when no key in the enum has the given value" do
      it "raises a KeyError" do
        subject = Fixtures::Enum::Empty

        error = assert_raises(KeyError) { subject.key(:foo) }
        assert_equal "no key found for value: :foo", error.message
        assert_equal subject, error.receiver, "should set the error receiver"
        assert_raises(ArgumentError) { error.key }
      end
    end
  end
end
