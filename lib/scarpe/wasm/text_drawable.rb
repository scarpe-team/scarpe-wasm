# frozen_string_literal: true

module Scarpe::WASM
  class TextDrawable < Drawable
  end

  class << self
    def default_wasm_text_drawable_with(element)
      wasm_class_name = "WASM#{element.capitalize}"
      wasm_drawable_class = Class.new(Scarpe::WASM::TextDrawable) do
        def initialize(properties)
          class_name = self.class.name.split("::")[-1]
          @html_tag = class_name.delete_prefix("WASM").downcase
          super
        end

        def element
          HTML.render do |h|
            h.send(@html_tag) { @content.to_s }
          end
        end
      end
      Scarpe::WASM.const_set wasm_class_name, wasm_drawable_class
    end
  end
end

Scarpe::WASM.default_wasm_text_widget_with(:code)
Scarpe::WASM.default_wasm_text_widget_with(:em)
Scarpe::WASM.default_wasm_text_widget_with(:strong)
