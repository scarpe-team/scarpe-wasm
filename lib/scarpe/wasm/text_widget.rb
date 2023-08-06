# frozen_string_literal: true

class Scarpe
  class WASMTextWidget < Scarpe::WASMWidget
  end

  class << self
    def default_wasm_text_widget_with(element)
      wasm_class_name = "WASM#{element.capitalize}"
      wasm_widget_class = Class.new(Scarpe::WASMTextWidget) do
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
      Scarpe.const_set wasm_class_name, wasm_widget_class
    end
  end
end

Scarpe.default_wasm_text_widget_with(:code)
Scarpe.default_wasm_text_widget_with(:em)
Scarpe.default_wasm_text_widget_with(:strong)
