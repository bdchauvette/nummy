# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".slice" do
    describe "when all of the given keys exist" do
      it "returns a new Enum consisting of the given keys" do
        orig = Fixtures::Enum::CardinalDirection
        sliced = orig.slice(:NORTH, :SOUTH)

        refute_same orig, sliced, "should return a new enum"

        expected = {
          NORTH: orig::NORTH,
          SOUTH: orig::SOUTH
        }

        assert_equal expected.to_h, sliced.to_h
      end

      it "returns the values in the order of the given keys" do
        orig = Fixtures::Enum::CardinalDirection

        (1..orig.pairs.size).each do |n|
          orig.pairs.permutation(n) do |permutation|
            keys = permutation.map(&:first)
            sliced = orig.slice(*keys)

            assert_equal permutation, sliced.pairs
          end
        end
      end
    end

    describe "when no keys are given" do
      it "returns a new empty enum" do
        orig = Fixtures::Enum::CardinalDirection
        sliced = orig.slice

        assert_operator sliced, :<, Nummy::Enum
        assert_empty sliced
      end
    end

    describe "when an unknown key is given" do
      it "raises a KeyError" do
        subject = Fixtures::Enum::Empty

        error = assert_raises(KeyError) { subject.slice(:foo) }
        assert_equal "key not found: :foo", error.message
        assert_equal :foo, error.key, "should set the error key"
        assert_equal subject, error.receiver, "should set the error receiver"
      end
    end
  end
end
