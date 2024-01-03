# frozen_string_literal: true

require "minitest/reporters"
require "minitest/autorun"

Minitest::Reporters.use!(
  if ENV["CI"]
    Minitest::Reporters::SpecReporter.new
  else
    Minitest::Reporters::DefaultReporter.new
  end
)
