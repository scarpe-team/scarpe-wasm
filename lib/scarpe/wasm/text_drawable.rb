# frozen_string_literal: true

module Scarpe::Wasm
  class TextDrawable < Drawable
  end

  class << self
    def default_wasm_text_drawable_with(element)
      wasm_class_name = element.capitalize
      wasm_drawable_class = Class.new(Scarpe::Wasm::TextDrawable) do
        def initialize(properties)
          class_name = self.class.name.split("::")[-1]
          @html_tag = class_name.delete_prefix("Wasm").downcase
          super
        end

        def element
          render(@html_tag) { @content.to_s }
        end
      end
      Scarpe::Wasm.const_set wasm_class_name, wasm_drawable_class
    end
  end
end

Scarpe::Wasm.default_wasm_text_drawable_with(:code)
Scarpe::Wasm.default_wasm_text_drawable_with(:em)
Scarpe::Wasm.default_wasm_text_drawable_with(:strong)
