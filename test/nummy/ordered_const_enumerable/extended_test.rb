# frozen_string_literal: true

require "test_helper"

describe Nummy::OrderedConstEnumerable do
  describe ".extended" do
    it "orders existing constants in sorted order before other constants" do
      permutations = 5.times.flat_map { |n| [n, n] }.permutation(2)

      permutations.each do |before_size, after_size|
        before_keys =
          before_size.times.to_a.shuffle.map { |n| :"BEFORE_KEY_#{n}" }

        after_keys = after_size.times.to_a.shuffle.map { |n| :"AFTER_KEY_#{n}" }

        subject =
          Module.new do
            before_keys.each { |key| const_set(key, :does_not_matter) }
            extend(Nummy::OrderedConstEnumerable)
            after_keys.each { |key| const_set(key, :does_not_matter) }
          end

        expected_names = [*before_keys.sort, *after_keys]

        assert_equal expected_names, subject.each_const_name.to_a
      end
    end
  end
end
