# frozen_string_literal: true

require_relative "wasm"
require_relative "wasm/wasm_local_display"

Shoes::DisplayService.set_display_service_class(Scarpe::WASMDisplayService)
