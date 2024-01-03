# frozen_string_literal: true

require "rubygems"
require "test_helper"

describe "Nummy::VERSION" do
  it "is a valid version string" do
    assert Gem::Version.correct?(Nummy::VERSION)
  end

  it "is not all zeros" do
    release = Gem::Version.new(Nummy::VERSION).release

    refute_equal "0.0.0", release.to_s
  end
end
