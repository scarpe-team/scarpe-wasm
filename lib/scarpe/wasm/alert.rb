# frozen_string_literal: true

module Scarpe::WASM
  class Alert < Drawable
    # display_properties = :width

    def initialize(properties)
      super

      bind("click") do
        send_self_event(event_name: "click")
      end
    end

    def element
      render("alert")
    end
  end
end
