# frozen_string_literal: true

require "test_helper"

describe Nummy::AutoSequenceable do
  subject { Class.new { extend Nummy::AutoSequenceable } }

  describe "#auto" do
    it "increments a zero-based counter by default" do
      assert_equal 0, subject.auto
      assert_equal 1, subject.auto
      assert_equal 2, subject.auto
    end

    it "works with next-able values" do
      assert_equal :a, subject.auto(:a)
      assert_equal :b, subject.auto
      assert_equal :c, subject.auto
    end

    it "works with succeedable values" do
      require "ipaddr"

      # IPAddr responds to #succ, but not #next.
      value = IPAddr.new "192.168.1.1"

      # Make sure the assumption in the comment above is correct :)
      refute_respond_to value, :next, "test value should not respond to #next"

      assert_equal IPAddr.new("192.168.1.1"), subject.auto(value)
      assert_equal IPAddr.new("192.168.1.2"), subject.auto
      assert_equal IPAddr.new("192.168.1.3"), subject.auto
    end

    it "resets the sequence when a new value is given" do
      assert_equal :a, subject.auto(:a)
      assert_equal :b, subject.auto
      assert_equal :c, subject.auto

      assert_equal 10, subject.auto(10)
      assert_equal 11, subject.auto
      assert_equal 12, subject.auto

      assert_equal :x, subject.auto(:x)
      assert_equal :y, subject.auto
      assert_equal :z, subject.auto

      assert_equal 98, subject.auto(98)
      assert_equal 99, subject.auto
      assert_equal 100, subject.auto
    end

    it "calculates using the given block" do
      assert_equal 0, (subject.auto { |n| n * 2 })
      assert_equal 2, subject.auto
      assert_equal 4, subject.auto
    end

    it "resets the value when a new block is given" do
      double = ->(n) { n * 2 }

      assert_equal 0, subject.auto(&double)
      assert_equal 2, subject.auto
      assert_equal 4, subject.auto

      triple = ->(n) { n * 3 }

      assert_equal 0, subject.auto(&triple)
      assert_equal 3, subject.auto
      assert_equal 6, subject.auto
    end

    it "allows specifying an initial value with a block" do
      double = ->(n) { n * 2 }

      assert_equal 20, subject.auto(10, &double)
      assert_equal 22, subject.auto
      assert_equal 24, subject.auto

      triple = ->(n) { n * 3 }

      assert_equal 300, subject.auto(100, &triple)
      assert_equal 303, subject.auto
      assert_equal 306, subject.auto
    end

    it "raises if the value cannot be incremented" do
      value = Object.new

      refute_respond_to value, :next, "test value should not respond to #next"
      refute_respond_to value, :succ, "test value should not respond to #next"
      error = assert_raises(TypeError) { subject.auto(value) }

      assert_equal "cannot increment #{value.inspect}: does not respond to #next or #succ",
                   error.message
    end
  end
end
