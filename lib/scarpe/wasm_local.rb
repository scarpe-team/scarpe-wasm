# frozen_string_literal: true

ENV['SCARPE_DEBUG'] = 'true'
ENV['SCARPE_DISPLAY_SERVICE'] = "wasm_local"

require "shoes"
require "lacci/scarpe_core"

require_relative "wasm"
require_relative "wasm/wasm_local_display"

require "scarpe/components/html"
require "scarpe/components/promises"

module Scarpe::WASM
  HTML = Scarpe::Components::HTML

  class Widget < Shoes::Linkable
    # This is where we would make the HTML renderer modular by choosing another
    require "scarpe/components/calzini"
    include Scarpe::Components::Calzini
  end
end

# For Wasm, use simple no-dependency printing logger
require "scarpe/components/print_logger"
Shoes::Log.instance = Scarpe::Components::PrintLogImpl.new
Shoes::Log.configure_logger(Shoes::Log::DEFAULT_LOG_CONFIG)


Shoes::DisplayService.set_display_service_class(Scarpe::WASM::DisplayService)
