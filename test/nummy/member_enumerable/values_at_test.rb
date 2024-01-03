# frozen_string_literal: true

require "test_helper"

describe Nummy::MemberEnumerable do
  describe ".values_at" do
    describe "when all of the given keys exist" do
      it "returns the values for the given keys of the enum" do
        subject =
          Fixtures::MemberEnumerable::ValueCollection[
            foo: 123,
            bar: 456,
            baz: 789
          ]

        assert_equal [123, 789], subject.values_at(:foo, :baz)
      end

      it "returns the values in the order of the given keys" do
        subject =
          Fixtures::MemberEnumerable::ValueCollection[
            foo: 123,
            bar: 456,
            baz: 789
          ]

        pairs = subject.each_pair.to_a

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
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

        assert_empty subject.values_at
      end
    end

    describe "when an unknown key is given" do
      it "raises a NoMethodError" do
        subject = Fixtures::MemberEnumerable::Empty[]

        error = assert_raises(NoMethodError) { subject.values_at(:foo) }

        assert_match(/\Aundefined method `foo'/, error.message)
      end
    end
  end
end
