# frozen_string_literal: true

# Can set in individual tests *before* requiring test_helper. Otherwise it will default to folio (local).
ENV["SCARPE_DISPLAY_SERVICE"] ||= "wasm"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "fileutils"
require "socket"

require "scarpe/components/unit_test_helpers"

## Capybara Setup

require "capybara"
require 'capybara/minitest'
Capybara.default_driver = :selenium_chrome_headless
Capybara.run_server = false
Capybara.app_host = "http://localhost:8080"

# In setup, this will change the Capybara driver
#Capybara.current_driver = :selenium_headless # example: use headless Firefox

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  # Make sure to call super in child-class teardown if there is one
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

TEST_DATA = {
  wasm_built: false,
}

# This ensures that a combined package is built for testing, once per test process.
class WasmPackageTestCase < CapybaraTestCase
  TEST_CACHE_DIR = File.expand_path(File.join __dir__, "../test/cache")
  TEST_CACHE_WASM = File.join(TEST_CACHE_DIR, "packed_ruby.wasm")

  MAX_SERVER_STARTUP_WAIT = 5.0

  def setup
    super if defined?(super)

    build_test_wasm_package
  end

  def build_test_wasm_package
    return if TEST_DATA[:wasm_built]

    Dir.chdir TEST_CACHE_DIR
    FileUtils.touch "src/APP_NAME.rb" # Use this to have a boilerplate name to search/replace

    # Need to use the TEST_CACHE_DIR Bundler env, *not* the one for the test harness.
    Bundler.with_unbundled_env do
      system("bundle exec wasify src/APP_NAME.rb") || raise("Couldn't wasify-build!")
    end

    TEST_DATA[:wasm_built] = true
  end

  def port_open?(ip, port_num)
    begin
      TCPSocket.new(ip, port_num)
    rescue Errno::ECONNREFUSED
      return false
    end
    return true
  end

  def wait_until_port_open(ip, port_num)
    t_start = Time.now
    loop do
      if Time.now - t_start > MAX_SERVER_STARTUP_WAIT
        raise "Server on port #{port_num} didn't start up in time!"
      end

      sleep 0.1
      return if port_open?(ip, port_num)
    end
  end

  def with_app_server(app_name, &block)
    app_name = app_name[0..-4] if app_name.end_with?(".rb")

    server_pid = nil
    Dir.chdir(TEST_CACHE_DIR) do
      File.write("src/#{app_name}.rb", File.read("#{TEST_CACHE_DIR}/../examples/#{app_name}.rb"))
      index_name = "index_#{app_name}.html"
      File.write(index_name, File.read("index.html").gsub("APP_NAME", app_name))
      server_pid = Kernel.spawn("bundle exec ruby -run -e httpd . -p 8080")
      wait_until_port_open("127.0.0.1", 8080)

      yield(index_name)
    end
  ensure
    Process.kill(9, server_pid) if server_pid
  end

  def with_app(app_file)
    with_app_server(app_file) do |index_file|
      visit("/#{index_file}")
      assert_selector("#wrapper-wvroot", wait: 5)
      assert_selector("#wrapper-wvroot div", wait: 5)
      yield
    end
  end

end

# Any final shutdown?
Minitest.after_run do
end

require "minitest/autorun"
