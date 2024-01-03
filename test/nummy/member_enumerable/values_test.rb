# frozen_string_literal: true

require "test_helper"

describe Nummy::MemberEnumerable do
  describe "#values" do
    it "returns an array of the member values" do
      subject = Fixtures::MemberEnumerable::ValueCollection[123, 456, 789]

      assert_equal [123, 456, 789], subject.values
    end
  end
end
