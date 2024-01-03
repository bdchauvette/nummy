# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".empty?" do
    describe "when the enum has pairs" do
      it "returns false" do
        keys = 10.times.map { |n| :"KEY_#{n}" }

        keys.size.times.drop(1).each do |expected_size|
          subject =
            Class.new(Nummy::Enum) do
              keys[0...expected_size].each { |key| const_set(key, auto) }
            end

          refute_empty subject
        end
      end
    end

    describe "when the enum has no pairs" do
      it "returns true" do
        subject = Fixtures::Enum::Empty

        assert_empty subject
      end
    end
  end
end
