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
SCARPE_WASM_DEFAULT_FILE_LOADER = loader

Shoes.add_file_loader loader

Shoes::FONTS.push(
  "Helvetica",
  "Arial",
  "Arial Black",
  "Verdana",
  "Tahoma",
  "Trebuchet MS",
  "Impact",
  "Gill Sans",
  "Times New Roman",
  "Georgia",
  "Palatino",
  "Baskerville",
  "Courier",
  "Lucida",
  "Monaco",
)

# When we require Wasm's shoes-spec it will fill this in on the host side
module Scarpe; module Test; end; end
require "shoes-spec"
Shoes::Spec.instance = Scarpe::Test

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

# Called when loading a Shoes app into the browser.
def browser_shoes_code(url, code)
  if url.end_with?(".sspec") || url.end_with?(".scas")
    # Segmented app - host will run the test code, we'll run the app
    _fm, segmap = Scarpe::Components::SegmentedFileLoader.front_matter_and_segments_from_file(code)
    app_code = segmap.values.first
    eval app_code
  elsif url.end_with?(".rb")
    # Standard Ruby Shoes app, just load it
    eval code
  else
    raise "ERROR! Unknown file extension for browser URL #{url.inspect}! Should end in .rb or .sspec!"
  end
end
