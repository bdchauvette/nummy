# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".inspect" do
    describe "when there is at least one pair" do
      it "returns a string containing the class name and pairs" do
        subject = Fixtures::Enum::CardinalDirection

        assert_equal "#<Fixtures::Enum::CardinalDirection NORTH=0 EAST=90 SOUTH=180 WEST=270>",
                     subject.inspect
      end

      it "uses #{Nummy::Enum.name} as name if enum does not have one" do
        subject =
          Class.new(Nummy::Enum) do |enum|
            Fixtures::Enum::CardinalDirection.each_pair do |key, value|
              enum.const_set(key, value)
            end
          end

        assert_equal "#<Nummy::Enum NORTH=0 EAST=90 SOUTH=180 WEST=270>",
                     subject.inspect
      end

      it "converts values using #inspect" do
        subject =
          Class.new(Nummy::Enum) do |enum|
            enum::FOO = :foo
            enum::BAR = :bar
          end

        assert_equal "#<Nummy::Enum FOO=:foo BAR=:bar>", subject.inspect
      end
    end

    describe "when there are no pairs" do
      it "returns a string containing the class name" do
        subject = Fixtures::Enum::Empty

        assert_equal "#<Fixtures::Enum::Empty>", subject.inspect
      end

      it "uses #{Nummy::Enum.name} as name if enum does not have one" do
        subject = Class.new(Nummy::Enum)

        assert_equal "#<Nummy::Enum>", subject.inspect
      end
    end
  end
end
