# frozen_string_literal: true

require "test_helper"

describe Nummy::Enum do
  describe ".value" do
    it "is aliased as .[]" do
      subject = Nummy::Enum.singleton_class

      assert_aliased subject, :value, as: :[]
    end

    describe "when there a matching key" do
      it "returns the value of the constant" do
        subject = Fixtures::Enum::CardinalDirection

        assert_equal subject::NORTH,
                     subject.value(:NORTH),
                     "should work with symbols"

        assert_equal subject::NORTH,
                     subject.value("NORTH"),
                     "should work with strings"
      end
    end

    describe "when there is no matching key" do
      it "raises a KeyError" do
        subject = Fixtures::Enum::Empty

        error = assert_raises(KeyError) { subject.value(:foo) }
        assert_equal "key not found: :foo", error.message
        assert_equal subject, error.receiver, "should set the error receiver"
        assert_equal :foo, error.key, "should set the error key"
        assert_nil error.cause, "should not have an error cause"
      end
    end

    describe "when the key is scoped" do
      it "raises a KeyError" do
        subject =
          Class.new(Nummy::Enum) do |outer|
            outer::Inner =
              Class.new(Nummy::Enum) { |inner| inner::KEY = :inner_key }
          end

        [:"Inner::KEY", "Inner::KEY"].each do |key|
          error = assert_raises(KeyError) { subject.value(key) }

          assert_equal "cannot use scoped enum key: #{key.inspect}",
                       error.message

          assert_equal key, error.key, "should set the key in the error"

          # stree-ignore
          assert_equal subject, error.receiver, "should set the receiver in the error"
        end
      end
    end
  end
end
