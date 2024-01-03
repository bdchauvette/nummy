# frozen_string_literal: true

# ==============================================================================
# Bundler
# ------------------------------------------------------------------------------
require "bundler/gem_tasks"

# ==============================================================================
# Console
# ------------------------------------------------------------------------------
desc "Open an IRB session preloaded with this library"
task :console do
  sh "bin/console"
end

desc "Alias of console"
task :c, [] => :console

# ==============================================================================
# Docs
# ------------------------------------------------------------------------------
desc "Runs a live-reloading server for viewing documentation"
task :docs do
  sh "yard server --reload"
end

# ==============================================================================
# Minitest
# ------------------------------------------------------------------------------
require "minitest/test_task"

Minitest::TestTask.create do |task|
  task.test_prelude = %(require "initializers/simplecov")
  task.framework = %(require "initializers/minitest")
  task.test_globs = ENV.fetch("TEST", "test/**/*_test.rb").split(",")
end

# ==============================================================================
# RuboCop
# ------------------------------------------------------------------------------
require "rubocop/rake_task"

RuboCop::RakeTask.new

# ==============================================================================
# SyntaxTree
# ------------------------------------------------------------------------------
require "syntax_tree/rake_tasks"

configure_syntax_tree = ->(task) do
  # should match the version in gemspec
  task.target_ruby_version = "3.2.0"

  task.source_files =
    FileList[
      "Gemfile",
      "Rakefile",
      ".simplecov",
      "nummy.gemspec",
      "lib/**/*.rb",
      "test/*.rb"
    ]
end

SyntaxTree::Rake::CheckTask.new(&configure_syntax_tree)
SyntaxTree::Rake::WriteTask.new(&configure_syntax_tree)

# ==============================================================================
# Default
# ------------------------------------------------------------------------------
task :default, [] => %i[test rubocop stree:check]
