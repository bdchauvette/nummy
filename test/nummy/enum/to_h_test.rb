# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".to_h" do
    it "returns a hash containing the key-value pairs of the enum" do
      subject = Fixtures::Enum::CardinalDirection

      expected = { NORTH: 0, EAST: 90, SOUTH: 180, WEST: 270 }

      assert_equal expected, subject.to_h
    end

    it "returns an empty hash when the enum is empty" do
      subject = Fixtures::Enum::Empty

      assert_empty(subject.to_h)
    end

    it "sets the hash entries in the same order as the enum" do
      pairs = 5.times.map { |n| [:"KEY_#{n}", n] }

      (1..pairs.size).each do |n|
        pairs.permutation(n) do |permutation|
          subject =
            Class.new(Nummy::Enum) do
              permutation.each { |key, value| const_set(key, value) }
            end

          assert_equal permutation.to_h,
                       subject.to_h,
                       "should return the keys in insertion order"
        end
      end
    end

    it "is aliased as .to_hash" do
      subject = Nummy::Enum.singleton_class

      assert_aliased subject, :to_h, as: :to_hash
    end

    it "allows the enum to be splatted" do
      enum = Fixtures::Enum::CardinalDirection
      splatted = {}.merge(**enum)

      expected = { NORTH: 0, EAST: 90, SOUTH: 180, WEST: 270 }

      assert_equal expected, splatted
    end
  end
end
