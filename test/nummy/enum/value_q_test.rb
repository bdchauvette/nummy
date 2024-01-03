# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".value?" do
    describe "when there is one key with the value" do
      it "returns true" do
        subject = Fixtures::Enum::CardinalDirection

        assert subject.value?(subject::NORTH)
      end
    end

    describe "when there are multiple keys in the enum with the value" do
      it "returns true" do
        target_value = :target_value
        pairs = 5.times.map { |n| [:"KEY_#{n}", target_value] }

        (1..pairs.size).each do |n|
          pairs.permutation(n) do |permutation|
            subject =
              Class.new(Nummy::Enum) do
                permutation.each { |key, value| const_set(key, value) }
              end

            assert subject.value?(target_value),
                   "should return the keys in insertion order"
          end
        end
      end
    end

    describe "when no key in the enum has the given value" do
      it "returns false" do
        subject = Fixtures::Enum::Empty

        refute subject.value?(:foo)
      end
    end
  end
end
