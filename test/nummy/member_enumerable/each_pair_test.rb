# frozen_string_literal: true

require "test_helper"

describe Nummy::MemberEnumerable do
  describe "#each_pair" do
    describe "with a block" do
      it "yields each member-value pair to the block" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

        actual_pairs = []
        subject.each_pair { |name, value| actual_pairs << [name, value] }

        expected_items = [[:foo, 123], [:bar, 456], [:baz, 789]]

        assert_equal expected_items, actual_pairs
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::MemberEnumerable::Empty[]

        actual_pairs = []
        subject.each_pair { |name, value| actual_pairs << [name, value] }

        assert_empty actual_pairs
      end

      it "returns self" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]
        result = subject.each_pair { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name-value pair" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

        assert_instance_of Enumerator, subject.each_pair

        expected_items = [[:foo, 123], [:bar, 456], [:baz, 789]]

        assert_equal expected_items, subject.each_pair.to_a
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::MemberEnumerable::Empty[]

        assert_empty subject.each_pair.to_a
      end
    end
  end
end
