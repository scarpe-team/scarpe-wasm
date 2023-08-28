# frozen_string_literal: true

require "scarpe/wasm/version"

# You can serve a packed_ruby.wasm file and index.html through whatever HTTP
# server you like. But Scarpe-Wasm has a simple Webrick setup built in.
class Scarpe::Wasm::HTTPServer
  def initialize(port: 8080, dir: ".")
    @port = port
    @dir = dir
  end

  # Start the HTTP server
  def start
    require "webrick"

    s = WEBrick::HTTPServer.new(Port: @port, DocumentRoot: @dir)

    (["TERM", "QUIT", "HUP", "INT"] & Signal.list.keys).each do |sig|
      Signal.trap(sig, proc { s.shutdown })
    end

    # Blocks the current thread until we get a signal or something goes surprisingly wrong
    s.start
  end
end
