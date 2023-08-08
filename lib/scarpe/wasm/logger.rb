# frozen_string_literal: true

require "shoes/log"
require "json"

class Scarpe::WASMLogImpl
  include Shoes::Log # for constants

  class WASMLogger
    def initialize(component_name)
      @comp_name = component_name
    end

    def error(msg)
      puts "#{@comp_name} error: #{msg}"
    end

    def warn(msg)
      puts "#{@comp_name} warn: #{msg}"
    end

    def debug(msg)
      puts "#{@comp_name} debug: #{msg}"
    end

    def info(msg)
      puts "#{@comp_name} info: #{msg}"
    end
  end

  def logger_for_component(component)
    WASMLogger.new(component.to_s)
  end

  def configure_logger(log_config)
    # For now, ignore
  end
end

Shoes::Log.instance = Scarpe::WASMLogImpl.new
Shoes::Log.configure_logger(Scarpe::Log::DEFAULT_LOG_CONFIG)
