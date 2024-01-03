# frozen_string_literal: true

require "test_helper"

describe Nummy::MemberEnumerable do
  describe "#size" do
    it "is aliased as .length" do
      assert_aliased Nummy::MemberEnumerable, :size, as: :length
    end

    it "returns the number of key-value pairs in the enum" do
      keys = 10.times.map { |n| :"key_#{n}" }

      keys.size.times.each do |expected_size|
        keys_subset = keys[0...expected_size]
        klass = Data.define(*keys_subset) { include Nummy::MemberEnumerable }
        subject = klass[*expected_size.times.to_a]

        assert_equal expected_size, subject.size
      end
    end
  end
end
