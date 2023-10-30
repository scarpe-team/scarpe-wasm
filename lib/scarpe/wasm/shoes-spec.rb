# frozen_string_literal: true

require "capybara"
require 'capybara/minitest'
#Capybara.default_driver = :selenium_chrome_headless
#Capybara.run_server = false
#Capybara.app_host = "http://localhost:8080"

# In setup, this will change the Capybara driver
#Capybara.current_driver = :selenium_headless # example: use headless Firefox

module Scarpe; module Wasm; end; end

module Scarpe::Wasm::PortUtils
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
class Scarpe::Wasm::CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  # Make sure to call super in child-class teardown if there is one
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
