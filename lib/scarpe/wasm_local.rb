# frozen_string_literal: true

ENV['SCARPE_DEBUG'] = 'true'
ENV['SCARPE_DISPLAY_SERVICE'] = "wasm_local"

require "shoes"
require "lacci/scarpe_core"

require "scarpe/components/string_helpers"

# For Wasm, use simple no-dependency printing logger
require "scarpe/components/print_logger"
Shoes::Log.instance = Scarpe::Components::PrintLogImpl.new
Shoes::Log.configure_logger(Shoes::Log::DEFAULT_LOG_CONFIG)

require "scarpe/components/segmented_file_loader"
loader = Scarpe::Components::SegmentedFileLoader.new
Shoes.add_file_loader loader

# TODO: Shoes::Spec
#if ENV["SHOES_SPEC_TEST"]
#  require_relative "shoes_spec"
#  Shoes::Spec.instance = Scarpe::Test
#end

require "scarpe/components/html"
module Scarpe::Wasm
  HTML = Scarpe::Components::HTML

  class Drawable < Shoes::Linkable
    require "scarpe/components/calzini"
    # This is where we would make the HTML renderer modular by choosing another
    include Scarpe::Components::Calzini
  end
end

require_relative "wasm"
require_relative "wasm/wasm_local_display"

Shoes::DisplayService.set_display_service_class(Scarpe::Wasm::DisplayService)
