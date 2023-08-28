# frozen_string_literal: true

# Scarpe WASM Display Service

# This file should be required on the Wasm side, not the Ruby side.
# So it's used to link to JS, and to instantiate widgets, but not
# for e.g. packaging.

require_relative "wasm/version"

require_relative "wasm/wasm_calls"
require_relative "wasm/web_wrangler"
require_relative "wasm/control_interface"

require_relative "wasm/widget"
require_relative "wasm/wasm_local_display"

require_relative "wasm/dimensions"
require_relative "wasm/html"

require_relative "wasm/spacing"
require_relative "wasm/star"
require_relative "wasm/radio"
require_relative "wasm/background"
require_relative "wasm/border"

require_relative "wasm/arc"
require_relative "wasm/font"

require_relative "wasm/app"
require_relative "wasm/para"
require_relative "wasm/slot"
require_relative "wasm/stack"
require_relative "wasm/flow"
require_relative "wasm/document_root"
require_relative "wasm/subscription_item"
require_relative "wasm/button"
require_relative "wasm/image"
require_relative "wasm/edit_box"
require_relative "wasm/edit_line"
require_relative "wasm/list_box"
require_relative "wasm/alert"
require_relative "wasm/span"
require_relative "wasm/shape"

require_relative "wasm/text_widget"
require_relative "wasm/link"
require_relative "wasm/line"
require_relative "wasm/video"
require_relative "wasm/check"
