# frozen_string_literal: true

require "scarpe/wasm/version"

# This file should never be compiled to Wasm. We can require things up at
# the top without worrying about Wasm compatibility.
require "fileutils"

# A lot of scarpe-wasm is designed to be run in a browser, compiled to Wasm.
# But some of it is to create and compile those packages.
module Scarpe::Wasm::Packaging
  # Create a Package object for the default built-wasm Package, used to run
  # random scarpe-wasm applications.
  def self.default_package
    Package.new(app_dir: default_package_dir, install_dir: scarpe_cache_dir + "/default")
  end

  # The cache directory under the user home directory where built wasm and
  # other Scarpe-Wasm cache data is kept.
  def self.scarpe_cache_dir
    unless ENV['HOME']
      raise "Can't find $HOME for default Wasm install directory!"
    end

    "#{ENV['HOME']}/.scarpe-wasm"
  end

  # Scarpe-Wasm includes a default package, used to create the built wasm
  # for running random Scarpe-Wasm apps. This is the directory containing it.
  def self.default_package_dir
    File.expand_path(__dir__ + "../default_package")
  end

  # This class is designed to build a package -- either a default package or
  # a custom package for a specific app directory.
  class Package
    attr_reader :app_dir
    attr_reader :install_dir

    # Create a Package object, while not yet performing any Package-related operations.
    #
    # @param app_dir [String] the directory containing application code and a Gemfile
    # @param install_dir [String] a directory to install the resulting built code to
    def initialize(app_dir: Dir.pwd, install_dir: nil)
      @app_dir = app_dir
      @install_dir = install_dir
    end

    # Normally a package will supply its own source files and Gemfile.
    # You can add a fake boilerplate source file, and add a default
    # Gemfile if one doesn't already exist, using this method.
    #
    # @return <void>
    def use_defaults
      Dir.chdir @app_dir do
        # Ensure src directory exists
        FileUtils.mkdir_p("src")

        FileUtils.touch "src/APP_NAME.rb" # Use this to have a boilerplate name to search/replace

        unless File.exist?("Gemfile")
          File.write("Gemfile", File.read("#{default_package_dir}/Gemfile"))
        end
      end
    end

    # Make sure expected files exist, and that bundle install has been run.
    # Print warnings if the package looks incomplete or incorrect.
    #
    # @param force [Boolean] re-run the setup even if it has already run in this process
    def setup(force: false)
      return if !force && @setup_done
      @setup_done = true

      Dir.chdir @app_dir do
        src_dir = File.expand_path "#{@app_dir}/src"

        unless File.exist?("src")
          puts "WARNING: expected to find #{File.expand_path("src").inspect} but it doesn't exist!"
        end

        unless File.exist?("Gemfile")
          # For now, require that the app supplies a Gemfile instead of having a default.
          raise "We need a Gemfile for packaging!"
        end

        # Ensure gems are installed and Gemfile.lock is fully up-to-date
        system("bundle install") || raise("Failed while running 'bundle install' in #{@app_dir.inspect}!")

        unless File.read("Gemfile.lock").include?("wasify")
          # Don't fail now, but this is probably going to fail when we attempt to package.
          puts "WARNING: your Gemfile does not include the wasify gem! It's needed for packaging."
        end
      end
    end

    # Build the package from its source files. Install it to its installation directory.
    #
    # @param force [Boolean] Build the package even if it has already been built by this process.
    def build(force: false)
      setup

      return if !force && @build_done
      @build_done = true

      Dir.chdir @app_dir do
        # Need to use the TEST_CACHE_DIR Bundler env, *not* the one for the test harness.
        Bundler.with_unbundled_env do
          system("bundle exec wasify src/APP_NAME.rb") || raise("Couldn't build using wasify!")
        end

        FileUtils.mv "packed.ruby", "index.html", @install_dir
      end
    end
  end
end
