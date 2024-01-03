# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".pairs" do
    it "returns the key-value pairs of the enum" do
      subject = Fixtures::Enum::CardinalDirection
      expected_pairs = [[:NORTH, 0], [:EAST, 90], [:SOUTH, 180], [:WEST, 270]]

      assert_equal expected_pairs, subject.pairs
    end

    it "returns an empty array if there are no pairs" do
      subject = Fixtures::Enum::Empty

      assert_empty subject.pairs
    end

    it "returns the keys in insertion order" do
      pairs = 5.times.map { |n| [:"KEY_#{n}", n] }

      (1..pairs.size).each do |n|
        pairs.permutation(n) do |permutation|
          subject =
            Class.new(Nummy::Enum) do
              permutation.each { |key, value| const_set(key, value) }
            end

          assert_equal permutation,
                       subject.pairs,
                       "should return the keys in insertion order"
        end
      end
    end
  end
end
