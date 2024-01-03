# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".size" do
    it "is aliased as .length" do
      subject = Nummy::Enum.singleton_class

      assert_aliased subject, :size, as: :length
    end

    it "returns the number of key-value pairs in the enum" do
      keys = 10.times.map { |n| :"KEY_#{n}" }

      keys.size.times.each do |expected_size|
        subject =
          Class.new(Nummy::Enum) do
            keys[0...expected_size].each { |key| const_set(key, auto) }
          end

        assert_equal expected_size, subject.size
      end
    end
  end
end
