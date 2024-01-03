# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".key?" do
    describe "when the given key exists" do
      it "returns true" do
        subject = Fixtures::Enum::CardinalDirection

        assert subject.key?(:NORTH), "should work with symbols"
        assert subject.key?("NORTH"), "should work with strings"
      end
    end

    describe "when the given key does not exist" do
      it "returns false" do
        subject = Fixtures::Enum::Empty

        refute subject.key?(:BEEP), "should work with symbols"
        refute subject.key?("BOOP"), "should work with strings"
      end
    end

    describe "when the given key is scoped" do
      it "returns false" do
        subject =
          Class.new(Nummy::Enum) do |outer|
            outer::Inner =
              Class.new(Nummy::Enum) { |inner| inner::KEY = :inner_key }
          end

        refute subject.key?(:"Inner::KEY"), "should work with symbols"
        refute subject.key?("Inner::KEY"), "should work with strings"
      end
    end
  end
end
