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
  def self.default_package(prepack: false)
    @default_package ||= Package.new(app_dir: default_package_dir, install_dir: scarpe_cache_dir + "/default", prepack:)
  end

  # The cache directory under the user home directory where built wasm and
  # other Scarpe-Wasm cache data is kept.
  def self.scarpe_cache_dir
    unless ENV['HOME']
      raise "Can't find $HOME for default Wasm install directory!"
    end

    File.expand_path "#{ENV['HOME']}/.scarpe-wasm"
  end

  # Scarpe-Wasm includes a default package, used to create the built wasm
  # for running random Scarpe-Wasm apps. This is the directory containing it.
  def self.default_package_dir
    File.expand_path(__dir__ + "/../../../default_package")
  end

  def self.ensure_default_build
    return if @checked_default_build

    packed_file = scarpe_cache_dir + "/default/packed_ruby.wasm"
    one_week = 7 * 24 * 60 * 60

    if !File.exist?(packed_file) || (Time.now - File.mtime(packed_file) > one_week)
      default_package.use_defaults
      default_package.build
    end

    @checked_default_build = true
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
    def initialize(app_dir: Dir.pwd, install_dir: nil, prepack: false)
      @app_dir = File.expand_path(app_dir)
      @install_dir = File.expand_path(install_dir) if install_dir
      @prepack = prepack
    end

    # Returns the directory of the prepack archive, if this package does prepacking.
    # Returns nil for packages that don't prepack.
    #
    # @return [String] path to prepack directory
    def prepack_dir
      return nil unless @prepack

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
        Bundler.with_unbundled_env do
          system("bundle install") || raise("Failed while running 'bundle install' in #{@app_dir.inspect}!")
        end

        unless File.read("Gemfile.lock").include?("wasify")
          # Don't fail now, but this is probably going to fail when we attempt to package.
          # TODO: how can we stop requiring wasify be in the Gemfile, as long as it's installed in
          # the path somewhere?
          puts "WARNING: your Gemfile does not include the wasify gem! It's needed for packaging."
        end
      end

      @setup_done = true
    end

    # It's possible to wind up with weird files after a failed build, including odd
    # permissions. Let's clean up all remaining files from previous builds so we can
    # start from a clean slate. This doesn't re-do setup tasks like "bundle install",
    # that's handled by {#build} and {#setup} steps.
    def clean_app_dir
      # We're blowing away all the build files.
      @build_done = false

      FileUtils.rm_rf "#{@app_dir}/3_2-wasm32-unknown-wasi-full-js"
      FileUtils.rm_rf "#{@app_dir}/ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz"
      FileUtils.rm_rf "#{@app_dir}/deps"
      FileUtils.rm_rf "#{@app_dir}/ruby.wasm"
      FileUtils.rm_rf "#{@app_dir}/index.html"
      bak_files = Dir.glob("#{@app_dir}/*.bak")
      unless bak_files.empty?
        FileUtils.rm_rf bak_files
      end
    end

    # Build the package from its source files. Install it to its installation directory.
    #
    # @param force [Boolean] Build the package even if it has already been built by this process.
    def build(force: false)
      setup(force:)

      return if !force && @build_done

      Dir.chdir @app_dir do
        # Need to use the TEST_CACHE_DIR Bundler env, *not* the one for the test harness.
        Bundler.with_unbundled_env do
          system("bundle exec wasify src/APP_NAME.rb") || raise("Couldn't build using wasify in #{File.expand_path(@app_dir)}!")

          # If we prepack, we do *two* builds -- create the package, create the debug prepack.
          # The prepack has to be done second because creating the regular build will wipe out
          # the prepack output dir.
          if @prepack
            system("bundle exec wasify prepack") || raise("Couldn't prepack using wasify in #{File.expand_path(@app_dir)}!")
          end

          # We replace wasify's index.html with our own
          File.write("index.html", app_index_text("http://localhost:8080/APP_NAME.rb"))
        end

        if !@prepack && @install_dir && File.expand_path(@app_dir) != File.expand_path(@install_dir)
          begin
            FileUtils.mkdir_p @install_dir
            FileUtils.mv "packed_ruby.wasm", @install_dir
            FileUtils.mv "index.html", @install_dir
          rescue
            STDERR.puts "Error while installing from #{@app_dir.inspect} to #{@install_dir.inspect}"
            raise
          end
        end
      end

      @build_done = true
    end

    def app_index_text(app_file_url)
      <<~INDEX_HTML
        <html>
        <script src="https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@latest/dist/browser.umd.js"></script>
        <script>
          const { DefaultRubyVM } = window["ruby-wasm-wasi"];
          const main = async () => {
            const response = await fetch("http://localhost:8080/packed_ruby.wasm");
            const buffer = await response.arrayBuffer();
            const module = await WebAssembly.compile(buffer);
            const { vm } = await DefaultRubyVM(module);
            window.RubyVM = vm;
            const shoes_app = await fetch("#{app_file_url}");

            vm.printVersion();
            vm.eval(`require "bundler/setup"; require "scarpe/wasm_local"`);
            shoes_code = await shoes_app.text();
            console.log(shoes_code);
            vm.eval(shoes_code);
          };

          main();
        </script>

        <body></body>

        </html>
      INDEX_HTML
    end

    # A built package file can be used to serve more or less arbitrary Shoes apps.
    # But it needs an HTML index file to load the app, and the app must be available
    # where an HTTP server can see it.
    def build_app_index(app_file)
      app_file_dir = File.dirname(app_file)
      app_name = File.basename(app_file)
      if app_file_dir != @app_dir
        FileUtils.cp app_file, "#{@install_dir}/#{app_name}"
      end

      index_name = "index_#{app_name}.html"

      index_contents = app_index_text("http://localhost:8080/#{app_name}")
      File.write "#{@install_dir}/#{index_name}", index_contents

      index_name
    end
  end
end
