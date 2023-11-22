# frozen_string_literal: true

require "capybara"
require 'capybara/minitest'

# We need the list of Drawable classes and the set of Shoes styles for each
require "shoes"

require "json"

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
    # @raise [Shoes::Error,Scarpe::Error] Exception raised if the application didn't start or the spec code raises an uncaught exception
    #
    # @yield the code to run using the ShoesSpec API
    def run_shoes_spec_code(index_uri = nil)
      visit(index_uri) if index_uri

      if has_selector?("#wrapper-wvroot div", wait: 10)
        # Load Shoes-Spec test code into the browser as Wasm
        page.execute_script "window.RubyVM.eval('require \"js\"; require \"scarpe/wasm/shoes-spec-browser\"')"

        yield
      else
        require 'pp'
        logs = page.driver.browser.logs.get(:browser)
        reduced_logs = logs.select do |log|
          log.level != "INFO" &&
            (log.level != "WARNING" || !log.message.include?("its extensions are not built"))
        end.map { |log| [log.level, log.message] }
        severe_logs = logs.select { |log| log.level == "SEVERE" }
        severe_msgs = severe_logs.map(&:message)
        STDERR.puts "LOGS:\n#{pp reduced_logs}"

        # Looks like the Shoes app never loaded
        # TODO: add a proper error class for this to Lacci and/or Scarpe-Wasm
        page_body = page.evaluate_script("document.body.outerHTML")
        raise Shoes::Error, "Scarpe-Wasm application never started! #{page_body} SEVERE LOGS: #{severe_msgs.inspect}"
      end
    end

    Shoes::Drawable.drawable_classes.each do |klass|
      d_name = klass.dsl_name
      define_method(d_name) do |*specs|
        CapybaraTestProxy.new(d_name, specs, page:)
      end
    end
  end

  class JSConnection
    def initialize(page:)
      @page = page
    end

    # Execute the Ruby code. Note that there is no return value
    #
    # @return [void]
    def ruby_exec(code)
      @page.execute_script "window.RubyVM.eval(#{JSON.dump code})"
    end

    # Execute the Ruby code. Get a JSON-serializable return value back.
    #
    # @return the JSON-serializable return value
    def ruby_eval(code)
      code = "window.RubyVM.eval(`JS.global[:window][:return_value] = JSON.dump(begin;#{code};end)`)"
      @page.execute_script code
      data = JSON.load @page.evaluate_script "window.return_value"

      if data.is_a?(Array) && data.size > 1
        case data[0]
        when "value"
          return data[1]
        when "shoes_obj"
          # ["shoes_obj", "button", 37] - for Shoes::Button w/ linkable_id 37
          return CapybaraTestProxy.new(data[1], "id:#{data[2]}", page: @page)
        else
          raise "Unrecognized data type from ruby_eval: #{data.inspect}"
        end
      else
        raise "Unrecognized return value from ruby_eval: #{data.inspect}"
      end
    end
  end

  class CapybaraTestProxy
    # The proxy ID is not normally the same as the Shoes linkable_id - it's internally assigned and arbitrary
    attr_reader :id

    @@proxy_counter = 1

    def initialize(drawable_type, query_by, page:)
      @id = @@proxy_counter
      @drawable_type = drawable_type
      @query_by = query_by
      @js_conn = JSConnection.new(page:)
      @@proxy_counter += 1

      d_class = Shoes::Drawable.drawable_class_by_name(drawable_type)
      raise(NoDrawablesFoundError, "Can't find Drawable class for #{drawable_type.inspect}!") if d_class.nil?

      # Define methods just on this one object
      s_class = self.singleton_class
      js_conn = @js_conn

      d_class.shoes_style_names.each do |style_name|
        s_class.define_method(style_name) do
          js_conn.ruby_eval("ShoesSpecBrowser.instance.proxy_method(#{@id}, #{style_name.inspect}, [])")
        end
      end

      [:click, :hover, :leave, :change].each do |event|
        s_class.define_method("trigger_#{event}") do |*args|
          js_conn.ruby_exec("ShoesSpecBrowser.instance.proxy_trigger(#{@id}, #{event.to_s.inspect}, #{serialize args})")
        end
      end

      s_class.define_method(:method_missing) do |m_name, *args|
        # Instance methods on the local Drawable subclass get forwarded
        if d_class.instance_methods.include?(m_name.to_sym)
          return js_conn.ruby_eval("ShoesSpecBrowser.instance.proxy_method(#{@id}, #{m_name.to_s.inspect}, #{serialize args})")
        end

        raise NoMethodError, "undefined method `to_ary' for #{s_class.inspect}"
      end

      s_class.define_method(:respond_to_missing) do |m_name, priv = false|
        # Instance methods on the local Drawable subclass get forwarded
        if d_class.instance_methods.include?(m_name.to_sym)
          return true
        end

        false
      end

      js_conn.ruby_exec("ShoesSpecBrowser.instance.create_query_proxy(#{@id}, #{drawable_type.inspect}, #{serialize query_by})")
    end

    def serialize(data)
      JSON.dump data
    end
  end
end
