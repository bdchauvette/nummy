# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".keys" do
    it "returns the keys of the enum" do
      subject = Fixtures::Enum::CardinalDirection

      assert_equal %i[NORTH EAST SOUTH WEST], subject.keys
    end

    it "returns an empty array if there are no keys" do
      subject = Fixtures::Enum::Empty

      assert_empty subject.keys
    end

    it "returns the keys in insertion order" do
      keys = 5.times.map { |n| :"KEY_#{n}" }

      (1..keys.size).each do |n|
        keys.permutation(n) do |permutation|
          subject =
            Class.new(Nummy::Enum) do
              permutation.each { |key| const_set(key, auto) }
            end

          assert_equal permutation,
                       subject.keys,
                       "should return the keys in insertion order"
        end
      end
    end
  end
end
