# frozen_string_literal: true

require "capybara"
require 'capybara/minitest'
#Capybara.default_driver = :selenium_chrome_headless
#Capybara.run_server = false
#Capybara.app_host = "http://localhost:8080"

# In setup, this will change the Capybara driver
#Capybara.current_driver = :selenium_headless # example: use headless Firefox

# We need the list of Drawable classes and the set of Shoes styles for each
require "shoes"

module Scarpe; end

module Scarpe::Wasm
  module PortUtils
    MAX_SERVER_STARTUP_WAIT = 5.0

    def port_working?(ip, port_num)
      begin
        TCPSocket.new(ip, port_num)
      rescue Errno::ECONNREFUSED
        return false
      end
      return true
    end

    def wait_until_port_working(ip, port_num, max_wait: MAX_SERVER_STARTUP_WAIT)
      t_start = Time.now
      loop do
        if Time.now - t_start > max_wait
          raise "Server on port #{port_num} didn't start up in time!"
        end

        sleep 0.1
        return if port_working?(ip, port_num)
      end
    end
  end

  # The ShoesSpec module implements the ShoesSpec testing language
  # for Scarpe::Wasm using Capybara and Minitest.
  class CapybaraTestCase < Minitest::Test
    include Capybara::DSL
    include Capybara::Minitest::Assertions

    # Make sure to call super in child-class teardown if there is one
    def teardown
      Capybara.reset_sessions!
      Capybara.use_default_driver
      super if defined?(super)
    end

    # Run the ShoesSpec code within the supplied block
    #
    # @yield the code to run using the ShoesSpec API
    def run_shoes_spec_code(index_uri = nil)
      visit(index_uri) if index_uri

      assert_selector("body", wait: 5)
      assert_selector("#wrapper-wvroot", wait: 5)
      assert_selector("#wrapper-wvroot div", wait: 5)
      page.execute_script "window.RubyVM.eval('require \"scarpe/wasm/shoes-spec-browser\"')"

      #STDERR.puts "BODY:\n" + page.evaluate_script("document.body.innerHTML")

      yield
    end

    Shoes::Drawable.drawable_classes.each do |klass|
      d_name = klass.dsl_name
      define_method(d_name) do |*specs|
        args = [d_name, *specs].map(&:to_s).map(&:inspect).join(",")
        drawable_id = page.execute_script("window.RubyVM.eval('ShoesSpecBrowser.instance.query_drawable_id(#{args})');")
      end
    end
  end
end
