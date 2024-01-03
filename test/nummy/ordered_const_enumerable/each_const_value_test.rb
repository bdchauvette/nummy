# frozen_string_literal: true

require "test_helper"

describe Nummy::OrderedConstEnumerable do
  describe "#each_const_value" do
    describe "with a block" do
      it "yields each constant value to the block" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        actual_items = []
        subject.each_const_value { |value| actual_items << value }

        expected_items = [0, 90, 180, 270]

        assert_equal expected_items, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        actual_items = []
        subject.each_const_value { |value| actual_items << value }

        assert_empty actual_items
      end

      it "returns self" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection
        result = subject.each_const_value { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name-value pair" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        assert_instance_of Enumerator, subject.each_const_value

        expected_items = [0, 90, 180, 270]
        actual_items = subject.each_const_value.to_a

        assert_equal expected_items, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        assert_empty subject.each_const_value.to_a
      end

      it "excludes inherited constants" do
        subject = Fixtures::OrderedConstEnumerable::Inherited
        actual_values = subject.each_const_value.to_a

        refute_includes actual_values, subject::INHERITED
      end
    end
  end
end
