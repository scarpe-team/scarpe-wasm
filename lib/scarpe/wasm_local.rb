# frozen_string_literal: true

ENV['SCARPE_DEBUG'] = 'true'
ENV['SCARPE_DISPLAY_SERVICE'] = "wasm_local"

require "shoes"
require "lacci/scarpe_core"

# For Wasm, use simple no-dependency printing logger
require "scarpe/components/print_logger"
Shoes::Log.instance = Scarpe::Components::PrintLogImpl.new
Shoes::Log.configure_logger(Shoes::Log::DEFAULT_LOG_CONFIG)

require_relative "wasm"
require_relative "wasm/wasm_local_display"

Shoes::DisplayService.set_display_service_class(Scarpe::WASMDisplayService)
