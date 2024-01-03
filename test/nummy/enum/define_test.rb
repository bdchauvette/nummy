# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".define" do
    describe "positional args" do
      it "creates a new Enum based on the given keyword args" do
        subject = Nummy::Enum.define(:FOO, :BAR, :BAZ)

        expected = { FOO: 0, BAR: 1, BAZ: 2 }

        assert_equal expected, subject.to_h
      end
    end

    describe "keyword args" do
      it "creates a new Enum based on the given keyword args" do
        subject = Nummy::Enum.define(FOO: 123, BAR: 456, BAZ: 789)

        expected = { FOO: 123, BAR: 456, BAZ: 789 }

        assert_equal expected, subject.to_h
      end
    end

    describe "when a block is given" do
      it "calls the block" do
        block_called = false
        Nummy::Enum.define(:FOO, :BAR, :BAZ) { block_called = true }

        assert block_called
      end

      it "yields the new enum to the block" do
        block_args = nil
        subject =
          Nummy::Enum.define(:FOO, :BAR, :BAZ) { |*args| block_args = args }

        assert_equal [subject],
                     block_args,
                     "should pass the enum's class to the block"
      end

      it "calls the block in the context of the new enum" do
        block_ctx = nil
        subject = Nummy::Enum.define { block_ctx = self }

        assert_equal subject, block_ctx
      end

      it "allows setting constants in the block" do
        subject =
          Nummy::Enum.define do
            self::FOO = 123
            self::BAR = 456
            self::BAZ = 789
          end

        expected = { FOO: 123, BAR: 456, BAZ: 789 }

        assert_equal expected, subject.to_h
      end

      it "calls the block after setting any constants" do
        block_pairs = nil
        Nummy::Enum.define(FOO: 123, BAR: 456) { block_pairs = pairs }

        expected = { FOO: 123, BAR: 456 }

        assert_equal expected, block_pairs.to_h
      end
    end

    describe "mixed args" do
      it "creates a new Enum based on the given keyword args" do
        subject = Nummy::Enum.define(:FOO, BAR: :kwarg) { self::BAZ = :block }

        expected = { FOO: 0, BAR: :kwarg, BAZ: :block }

        assert_equal expected, subject.to_h
      end
    end
  end
end
