# frozen_string_literal: true

require "test_helper"

describe Nummy::ConstEnumerable do
  describe "#each_const_name" do
    describe "with a block" do
      it "yields each constant name to the block" do
        subject = Fixtures::ConstEnumerable::CardinalDirection

        actual_names = []
        subject.each_const_name { |name| actual_names << name }

        expected_names = %i[NORTH EAST SOUTH WEST]

        assert_equal_items expected_names, actual_names
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::ConstEnumerable::Empty

        actual_names = []
        subject.each_const_name { |name| actual_names << name }

        assert_empty actual_names
      end

      it "excludes inherited constants" do
        subject = Fixtures::ConstEnumerable::Inherited

        actual_names = []
        subject.each_const_name { |name| actual_names << name }

        refute_includes actual_names, :INHERITED
      end

      it "returns self" do
        subject = Fixtures::ConstEnumerable::CardinalDirection
        result = subject.each_const_name { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name" do
        subject = Fixtures::ConstEnumerable::CardinalDirection

        assert_instance_of Enumerator, subject.each_const_name

        expected_names = %i[NORTH EAST SOUTH WEST]
        actual_names = subject.each_const_name.to_a

        assert_equal_items expected_names, actual_names
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::ConstEnumerable::Empty

        assert_empty subject.each_const_name.to_a
      end

      it "excludes inherited constants" do
        subject = Fixtures::ConstEnumerable::Inherited
        actual_names = subject.each_const_name.to_a

        refute_includes actual_names, :INHERITED
      end
    end
  end
end
