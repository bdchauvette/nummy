# frozen_string_literal: true

require "test_helper"

describe Nummy::ConstEnumerable do
  describe "#each_const_value" do
    describe "with a block" do
      it "yields each constant value to the block" do
        subject = Fixtures::ConstEnumerable::CardinalDirection

        actual_values = []
        subject.each_const_value { |value| actual_values << value }

        expected_items = [0, 90, 180, 270]

        assert_equal_items expected_items, actual_values
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::ConstEnumerable::Empty

        actual_values = []
        subject.each_const_value { |value| actual_values << value }

        assert_empty actual_values
      end

      it "excludes inherited constants" do
        subject = Fixtures::ConstEnumerable::Inherited

        actual_values = []
        subject.each_const_value { |name| actual_values << name }

        refute_includes actual_values, subject::INHERITED
      end

      it "returns self" do
        subject = Fixtures::ConstEnumerable::CardinalDirection
        result = subject.each_const_value { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name-value pair" do
        subject = Fixtures::ConstEnumerable::CardinalDirection

        assert_instance_of Enumerator, subject.each_const_value

        expected_items = [0, 90, 180, 270]
        actual_values = subject.each_const_value.to_a

        assert_equal_items expected_items, actual_values
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::ConstEnumerable::Empty

        assert_empty subject.each_const_value.to_a
      end

      it "excludes inherited constants" do
        subject = Fixtures::ConstEnumerable::Inherited
        actual_values = subject.each_const_value.to_a

        refute_includes actual_values, subject::INHERITED
      end
    end
  end
end
