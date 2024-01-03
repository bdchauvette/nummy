# frozen_string_literal: true

require_relative "lib/nummy/version"

Gem::Specification.new do |spec|
  spec.name = "nummy"
  spec.version = Nummy::VERSION
  spec.authors = ["Benjamin Chauvette"]
  spec.email = ["ben@chvtt.net"]

  spec.summary = "Tasty enumeration utilities"

  spec.description = <<~DESC
    Nummy provides utilities that that build on Ruby's Enumerable module to
    provide functionality like enumerated types ("enums"), enumerating over
    constants in a module, and enumerating over the members of data classes.

    This module does NOT add additional methods to the Enumerable module, or
    change its behavior in any way.
  DESC

  spec.homepage = "https://github.com/bdchauvette/nummy"
  spec.license = "MIT-0"

  # Requires 3.2.0 because of using +const_added+ to track constant insertion order.
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files =
    Dir.chdir(__dir__) do
      Dir[
        "lib/**/*",
        # "sig/**/*", # someday...
        "CHANGELOG.md",
        "LICENSE.TXT",
        "README.md"
      ]
    end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-packaging"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-yard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-erb"
  spec.add_development_dependency "simplecov-lcov"
  spec.add_development_dependency "syntax_tree"
  spec.add_development_dependency "webrick"
  spec.add_development_dependency "yard"
end
