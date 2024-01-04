# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".to_attribute" do
    it "returns a hash containing the snake_cased key-value pairs of the enum" do
      require "active_support/inflector"

      subject =
        Class.new(Nummy::Enum) do |enum|
          # Disable naming conventions so that we can test that we're using
          # the inflector, and not just .downcase or a simple regex.
          # rubocop:disable Naming/ConstantName

          enum::SHOUTY_CASE = 0
          enum::PascalCase = 1
          enum::Mixed_Case = 2
          enum::ABBRCase = 3 # acronyms & abbreviations

          # rubocop:enable Naming/ConstantName
        end

      expected = { shouty_case: 0, pascal_case: 1, mixed_case: 2, abbr_case: 3 }

      assert_equal expected, subject.to_attribute
    end
  end
end
