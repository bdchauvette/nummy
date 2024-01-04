# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".to_attribute" do
    subject do
      Class.new(Nummy::Enum) do |enum|
        # Disable naming conventions so that we can test that we're using
        # the inflector, and not just .downcase or a simple regex.
        # rubocop:disable Naming/ConstantName

        enum::SCREAMING_SNAKE_CASE= 0
        enum::UpperCamelCase = 1
        enum::Mixed_Case = 2
        enum::ABBRCase = 3 # acronyms & abbreviations

        # rubocop:enable Naming/ConstantName
      end
    end

    describe "when no block is given" do
      describe "when String#underscore is defined" do
        it "transforms keys using String#underscore" do
          actual =
            ForkedProc.call do
              # Avoid loading ActiveSupport into the main test process
              require "active_support/core_ext/string/inflections"
              subject.to_attribute
            end

          expected = {
            screaming_snake_case: 0,
            upper_camel_case: 1,
            mixed_case: 2,
            abbr_case: 3
          }

          assert_equal expected, actual
        end
      end

      describe "when String#underscore is NOT defined" do
        it "transforms keys using Symbol#downcase" do
          expected = {
            screaming_snake_case: 0,
            uppercamelcase: 1,
            mixed_case: 2,
            abbrcase: 3
          }

          assert_equal expected, subject.to_attribute
        end
      end
    end

    describe "when a block is given" do
      it "transforms the keys with the given block" do
        expected = {
          SCREAMING_SNAKE_CASE: 0,
          UPPERCAMELCASE: 1,
          MIXED_CASE: 2,
          ABBRCASE: 3
        }

        assert_equal expected, subject.to_attribute(&:upcase)
      end
    end
  end
end
