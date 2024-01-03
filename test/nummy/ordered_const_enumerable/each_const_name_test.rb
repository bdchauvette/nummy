# frozen_string_literal: true

require "test_helper"

describe Nummy::OrderedConstEnumerable do
  describe "#each_const_name" do
    describe "with a block" do
      it "yields each constant name to the block" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        actual_items = []
        subject.each_const_name { |name| actual_items << name }

        expected_items = %i[NORTH EAST SOUTH WEST]

        assert_equal expected_items, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        actual_items = []
        subject.each_const_name { |name| actual_items << name }

        assert_empty actual_items
      end

      it "excludes inherited constants" do
        subject = Fixtures::OrderedConstEnumerable::Inherited

        actual_values = []
        subject.each_const_value { |name| actual_values << name }

        refute_includes actual_values, subject::INHERITED
      end

      it "returns self" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection
        result = subject.each_const_name { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        assert_instance_of Enumerator, subject.each_const_name

        expected_names = %i[NORTH EAST SOUTH WEST]
        actual_items = subject.each_const_name.to_a

        assert_equal_items expected_names, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        assert_empty subject.each_const_name.to_a
      end

      it "excludes inherited constants" do
        subject = Fixtures::OrderedConstEnumerable::Inherited
        actual_names = subject.each_const_name.to_a

        refute_includes actual_names, :INHERITED
      end
    end
  end
end
