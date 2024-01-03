# frozen_string_literal: true

require "test_helper"

describe Nummy::MemberEnumerable do
  describe "#each_pair" do
    describe "with a block" do
      it "yields each member value to the block" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

        actual_values = []
        subject.each { |value| actual_values << value }

        expected_items = [123, 456, 789]

        assert_equal expected_items, actual_values
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::MemberEnumerable::Empty[]

        actual_values = []
        subject.each { |value| actual_values << value }

        assert_empty actual_values
      end

      it "returns self" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]
        result = subject.each { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name-value pair" do
        subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

        assert_instance_of Enumerator, subject.each

        expected_items = [123, 456, 789]

        assert_equal expected_items, subject.each.to_a
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::MemberEnumerable::Empty[]

        assert_empty subject.each.to_a
      end
    end
  end
end
