# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".merge" do
    describe "when no block is given" do
      it "merges each given enum into a new enum" do
        a = Class.new(Nummy::Enum) { |enum| enum::FOO = :foo }
        b = Class.new(Nummy::Enum) { |enum| enum::BAR = :bar }
        c = Class.new(Nummy::Enum) { |enum| enum::BAZ = :baz }

        merged = a.merge(b, c)

        refute_same a, merged, "should return a new enum"
        assert_equal({ FOO: :foo, BAR: :bar, BAZ: :baz }, merged.to_h)
      end

      it "preserves insertion order" do
        a =
          Class.new(Nummy::Enum) do |enum|
            enum::FOO = :foo_a
            enum::BAR = :bar_a
          end

        b =
          Class.new(Nummy::Enum) do |enum|
            enum::BAZ = :baz_b
            enum::FOO = :foo_b
            enum::BAR = :bar_b
          end

        c =
          Class.new(Nummy::Enum) do |enum|
            enum::QUX = :qux_c
            enum::BAR = :bar_c
            enum::FOO = :foo_c
            enum::BAZ = :baz_c
          end

        merged = a.merge(b, c)

        expected = {
          FOO: :foo_c, # first key from a, value from c
          BAR: :bar_c, # first key from a, value from c
          BAZ: :baz_c, # first new key in b, value from c
          QUX: :qux_c # first new key in c, value from c
        }

        assert_equal expected, merged.to_h
      end

      it "returns an empty enum when all enums are empty" do
        a = Class.new(Nummy::Enum)
        b = Class.new(Nummy::Enum)
        c = Class.new(Nummy::Enum)

        merged = a.merge(b, c)

        assert_empty(merged.to_h)
      end

      it "returns original enum when no other enums are given" do
        orig = Fixtures::Enum::CardinalDirection
        merged = orig.merge

        assert_same orig, merged
      end
    end

    describe "when a block is given" do
      it "is called for each duplicate key-value pair" do
        a =
          Class.new(Nummy::Enum) do |enum|
            enum::FOO = :foo_a
            enum::BAR = :bar_a
          end

        b =
          Class.new(Nummy::Enum) do |enum|
            enum::BAZ = :baz_b
            enum::FOO = :foo_b
            enum::BAR = :bar_b
          end

        c =
          Class.new(Nummy::Enum) do |enum|
            enum::QUX = :qux_c
            enum::BAR = :bar_c
            enum::FOO = :foo_c
            enum::BAZ = :baz_c
          end

        block_args = []

        a.merge(b, c) do |key, old_value, new_value|
          block_args << [key, old_value, new_value]
          new_value
        end

        expected = [
          [:FOO, :foo_a, :foo_b],
          [:BAR, :bar_a, :bar_b],
          [:BAR, :bar_b, :bar_c],
          [:FOO, :foo_b, :foo_c],
          [:BAZ, :baz_b, :baz_c],
        ]

        assert_equal expected, block_args
      end
    end
  end
end
