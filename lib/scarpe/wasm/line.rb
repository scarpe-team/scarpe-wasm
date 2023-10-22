# frozen_string_literal: true

module Scarpe::WASM
  class Line < Drawable
    def initialize(properties)
      super(properties)
    end

    def element
      render("line")
    end
  end
end
