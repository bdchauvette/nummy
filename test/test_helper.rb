# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "initializers/simplecov"
require "initializers/minitest"

require "support/assertions"
require "support/fixtures"
require "support/utils"

require "nummy"
