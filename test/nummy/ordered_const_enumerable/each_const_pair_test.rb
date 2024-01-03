# frozen_string_literal: true
require "test_helper"

describe Nummy::OrderedConstEnumerable do
  describe "#each_const_pair" do
    it "is aliased as #each" do
      assert_aliased Nummy::OrderedConstEnumerable, :each_const_pair, as: :each
    end

    describe "with a block" do
      it "yields each name-value pair to the block" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        actual_items = []
        subject.each_const_pair { |key, value| actual_items << [key, value] }

        expected_items = [[:NORTH, 0], [:EAST, 90], [:SOUTH, 180], [:WEST, 270]]

        assert_equal expected_items, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        actual_items = []
        subject.each_const_pair { |key, value| actual_items << [key, value] }

        assert_empty actual_items
      end

      it "excludes inherited constants" do
        subject = Fixtures::ConstEnumerable::Inherited

        actual_pairs = []
        subject.each_const_pair { |name, value| actual_pairs << [name, value] }

        refute_includes actual_pairs.map(&:first), :INHERITED
      end

      it "returns self" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection
        result = subject.each_const_pair { pass }

        assert_equal subject, result
      end
    end

    describe "without a block" do
      it "returns an enumerator that iterates over each name-value pair" do
        subject = Fixtures::OrderedConstEnumerable::CardinalDirection

        assert_instance_of Enumerator, subject.each_const_pair

        expected_items = [[:NORTH, 0], [:EAST, 90], [:SOUTH, 180], [:WEST, 270]]
        actual_items = subject.each_const_pair.to_a

        assert_equal expected_items, actual_items
      end

      it "works when there are no constants in the group" do
        subject = Fixtures::OrderedConstEnumerable::Empty

        assert_empty subject.each_const_pair.to_a
      end

      it "excludes inherited constants" do
        subject = Fixtures::OrderedConstEnumerable::Inherited
        actual_pairs = subject.each_const_pair.to_a

        refute_includes actual_pairs.map(&:first), :INHERITED
      end
    end
  end
end
