# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".values" do
    it "returns the values of the enum" do
      subject = Fixtures::Enum::CardinalDirection

      assert_equal [0, 90, 180, 270], subject.values
    end

    it "returns an empty array if there are no keys" do
      subject = Fixtures::Enum::Empty

      assert_empty subject.values
    end

    it "returns the values in insertion order" do
      pairs = 5.times.map { |n| [:"KEY_#{n}", n] }

      (1..pairs.size).each do |n|
        pairs.permutation(n) do |permutation|
          subject =
            Class.new(Nummy::Enum) do
              permutation.each { |key, value| const_set(key, value) }
            end

          values = permutation.map(&:last)

          assert_equal values,
                       subject.values,
                       "should return the keys in insertion order"
        end
      end
    end
  end
end
