# frozen_string_literal: true

class Scarpe
  # This is the simplest type of WASM DisplayService. It creates WASM widgets
  # corresponding to Shoes widgets, manages the WASM and its DOM tree, and
  # generally keeps the Shoes/WASM connection working.
  #
  # This is an in-process WASM-based display service, with all the limitations that
  # entails. Slow handlers will crash, ending this display service will end the
  # process, too many or too large evals can crash the process, etc.
  # Frequently it's better to use a RelayDisplayService to a second
  # process containing one of these.
  class WASMDisplayService < Shoes::DisplayService
    include Shoes::Log

    class << self
      attr_accessor :instance
    end

    # The ControlInterface is used to handle internal events in WASM Scarpe
    attr_reader :control_interface

    # The DocumentRoot is the top widget of the WASM-side widget tree
    attr_reader :doc_root

    # app is the Scarpe::WASMApp
    attr_reader :app

    # wrangler is the Scarpe::WebWrangler
    attr_reader :wrangler

    # This is called before any of the various WASMWidgets are created, to be
    # able to create them and look them up.
    def initialize
      if WASMDisplayService.instance
        raise "ERROR! This is meant to be a singleton!"
      end

      WASMDisplayService.instance = self

      super()
      log_init("WASM::WASMDisplayService")

      @display_widget_for = {}
    end

    # Create a WASM display widget for a specific Shoes widget, and pair it with
    # the linkable ID for this Shoes widget.
    #
    # @param widget_class_name [String] The class name of the Shoes widget, e.g. Shoes::Button
    # @param widget_id [String] the linkable ID for widget events
    # @param properties [Hash] a JSON-serialisable Hash with the widget's display properties
    # @return [WASMWidget] the newly-created WASM widget
    def create_display_widget_for(widget_class_name, widget_id, properties)
      if widget_class_name == "App"
        unless @doc_root
          raise "WASMDocumentRoot is supposed to be created before WASMApp!"
        end

        display_app = Scarpe::WASMApp.new(properties)
        display_app.document_root = @doc_root
        @control_interface = display_app.control_interface
        @control_interface.doc_root = @doc_root
        @app = @control_interface.app
        @wrangler = @control_interface.wrangler

        set_widget_pairing(widget_id, display_app)

        return display_app
      end

      # Create a corresponding display widget
      display_class = Scarpe::WASMWidget.display_class_for(widget_class_name)
      display_widget = display_class.new(properties)
      set_widget_pairing(widget_id, display_widget)

      if widget_class_name == "DocumentRoot"
        # WASMDocumentRoot is created before WASMApp. Mostly doc_root is just like any other widget,
        # but we'll want a reference to it when we create WASMApp.
        @doc_root = display_widget
      end

      display_widget
    end

    # Destroy the display service and the app. Quit the process (eventually.)
    #
    # @return [void]
    def destroy
      @app.destroy
      WASMDisplayService.instance = nil
    end
  end
end
