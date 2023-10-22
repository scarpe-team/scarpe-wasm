# frozen_string_literal: true

module Scarpe::WASM
  class Star < Drawable
    def initialize(properties)
      super(properties)
    end

    def element(&block)
      render("star", &block)
    end
  end
end
