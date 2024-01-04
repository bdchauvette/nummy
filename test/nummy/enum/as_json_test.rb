# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".as_json" do
    it "returns a hash containing the key-value pairs of the enum" do
      subject = Fixtures::Enum::CardinalDirection

      expected = { "NORTH" => 0, "EAST" => 90, "SOUTH" => 180, "WEST" => 270 }

      assert_equal expected, subject.as_json
    end

    it "returns an empty hash when the enum is empty" do
      subject = Fixtures::Enum::Empty

      assert_empty subject.as_json
    end
  end
end
