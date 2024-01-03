# frozen_string_literal: true

def enable_coverage!
  require "simplecov"
  require "simplecov-erb"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.output_directory = "coverage"
    c.lcov_file_name = "lcov.info"
  end

  SimpleCov.start do
    # Explicitly track all files in the lib directory, even if they aren't
    # required by anything.
    track_files "lib/**/*.rb"

    # Exclude test files from coverage.
    add_filter "test"

    # The version file *is* actually tested, but it gets loaded before simplecov,
    # so it can't be instrumented.
    add_filter "lib/nummy/version.rb"

    enable_coverage :line
    enable_coverage :branch

    minimum_coverage line: 100, branch: 100

    formatter SimpleCov::Formatter::MultiFormatter.new(
                [
                  SimpleCov::Formatter::ERBFormatter,
                  SimpleCov::Formatter::HTMLFormatter,
                  SimpleCov::Formatter::LcovFormatter
                ]
              )
  end
end

def coverage_enabled?
  # always enable in CI
  return true if ENV["CI"]

  # enable if COVERAGE is set to "true" or "1"
  %w[true 1].include?(ENV.fetch("COVERAGE", nil))
end

enable_coverage! if coverage_enabled?
