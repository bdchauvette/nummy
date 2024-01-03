# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".fetch" do
    describe "when only a key is given" do
      describe "when the key exists" do
        it "returns the value for the key" do
          subject = Fixtures::Enum::CardinalDirection

          value = subject.fetch(:NORTH)

          assert_equal subject::NORTH, value
        end
      end

      describe "when the key does not exist" do
        it "raises a KeyError" do
          error = assert_raises(KeyError) { Fixtures::Enum::Empty.fetch(:FOO) }
          assert_equal "key not found: :FOO", error.message
        end
      end
    end

    describe "when a fallback value is given" do
      describe "when the key exists" do
        it "returns the value for the key" do
          subject = Fixtures::Enum::CardinalDirection

          value = subject.fetch(:NORTH, 360)

          assert_equal subject::NORTH, value
        end
      end

      describe "when the key does not exist" do
        it "returns the fallback value" do
          subject = Fixtures::Enum::Empty
          value = subject.fetch(:FOO, 123)

          assert_equal 123, value
        end
      end
    end

    describe "when a block is given" do
      describe "when the key exists" do
        it "returns the value for the key" do
          subject = Fixtures::Enum::CardinalDirection

          block_called = false
          value = subject.fetch(:NORTH) { block_called = true }

          assert_equal subject::NORTH, value
          refute block_called, "should not call the block"
        end
      end

      describe "when the key does not exist" do
        it "returns the block value" do
          subject = Fixtures::Enum::Empty

          block_called = false
          block_args = nil

          value =
            subject.fetch(:FOO) do |*args|
              block_called = true
              block_args = args
              123
            end

          assert_equal 123, value
          assert block_called, "should call the block"
          assert_equal [:FOO], block_args, "should call the block with the key"
        end
      end
    end

    describe "when a fallback value and block are given" do
      it "warns that the block supersedes fallback value" do
        subject = Fixtures::Enum::Empty

        warn_called = false
        warn_msg = nil

        mock_warn = ->(msg) do
          warn_called = true
          warn_msg = msg
          nil
        end

        subject.stub :warn, mock_warn do
          subject.fetch(:FOO, :fallback) { :block }
        end

        assert warn_called, "should call .warn"
        assert_equal "block supersedes default value argument", warn_msg
      end

      it "uses the block value" do
        subject = Fixtures::Enum::Empty

        subject.stub :warn, nil do
          value = subject.fetch(:FOO, :fallback) { :block }

          assert_equal :block, value
        end
      end
    end

    describe "when more than two args are given" do
      it "raises a KeyError" do
        subject = Fixtures::Enum::Empty

        error =
          assert_raises(ArgumentError) do
            subject.fetch(:FOO, :fallback, :extra)
          end

        assert_equal "wrong number of arguments (given 3, expected 1..2)",
                     error.message
      end
    end
  end
end
