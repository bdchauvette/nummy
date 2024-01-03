# frozen_string_literal: true

require "test_helper"
require "pp"

describe Nummy::Enum do
  describe ".pretty_print" do
    describe "when there is at least one pair" do
      it "prints the name of the constant and each of the name-value pairs" do
        subject = Fixtures::Enum::CardinalDirection

        actual = PP.pp(subject, String.new)
        expected = "#<#{subject.name} NORTH=0 EAST=90 SOUTH=180 WEST=270>\n"

        assert_equal expected, actual
      end

      it "breaks at the name-value pair boundaries" do
        subject = Fixtures::Enum::CardinalDirection

        actual = PP.pp(subject, String.new, 3)
        expected = <<~EXPECTED
          #<#{subject.name}
           NORTH=0
           EAST=90
           SOUTH=180
           WEST=270>
        EXPECTED

        assert_equal expected, actual
      end

      it "uses #{Nummy::Enum.name} as name if enum does not have one" do
        subject =
          Class.new(Nummy::Enum) do |enum|
            Fixtures::Enum::CardinalDirection.each_pair do |key, value|
              enum.const_set(key, value)
            end
          end

        actual = PP.pp(subject, String.new, 3)
        expected = <<~EXPECTED
          #<Nummy::Enum
           NORTH=0
           EAST=90
           SOUTH=180
           WEST=270>
        EXPECTED

        assert_equal expected, actual
      end

      it "converts values using #inspect" do
        subject =
          Class.new(Nummy::Enum) do |enum|
            enum::FOO = :foo
            enum::BAR = :bar
          end

        actual = PP.pp(subject, String.new, 3)
        expected = <<~EXPECTED
          #<Nummy::Enum
           FOO=:foo
           BAR=:bar>
        EXPECTED

        assert_equal expected, actual
      end
    end

    describe "when there are no pairs" do
      it "returns a string containing the class name" do
        subject = Fixtures::Enum::Empty

        actual = PP.pp(subject, String.new, 3)
        expected = "#<Fixtures::Enum::Empty>\n"

        assert_equal expected, actual
      end

      it "uses #{Nummy::Enum.name} as name if enum does not have one" do
        subject = Class.new(Nummy::Enum)

        actual = PP.pp(subject, String.new, 3)
        expected = "#<Nummy::Enum>\n"

        assert_equal expected, actual
      end
    end
  end
end
