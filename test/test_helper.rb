# frozen_string_literal: true

# Can set in individual tests *before* requiring test_helper. Otherwise it will default to folio (local).
ENV["SCARPE_DISPLAY_SERVICE"] ||= "wasm"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "scarpe"
require "scarpe/wasm"

require "minitest/autorun"
