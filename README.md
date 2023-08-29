# Scarpe::Wasm

Scarpe is a re-implementation of the Shoes GUI library for Ruby with more modern dependencies and with support for current Ruby versions. Scarpe supports different swappable display libraries, allowing it to run with various devices.

Using Scarpe you can turn a few lines of code into a small GUI application.

The Wasm display library for Scarpe was initially written by Giovanni Borgh, and adopted by the Scarpe team.

Scarpe-Wasm is under very active development. You should expect everything about it to change rapidly, with limited stability, for the foreseeable future. If you want to use it for yourself, consider forking it or joining the team in developing it.

## Installation

You'll need to [install wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs#installation) for this library to work.

Here's how that's done for the specific current version needed by wasify:

``` bash
$ export WASI_VFS_VERSION=0.1.1

# For x86_64 macOS host machine
$ curl -LO "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v${WASI_VFS_VERSION}/wasi-vfs-cli-x86_64-apple-darwin.zip"
$ unzip wasi-vfs-cli-x86_64-apple-darwin.zip

# For arm64 macOS host machine
$ curl -LO "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v${WASI_VFS_VERSION}/wasi-vfs-cli-aarch64-apple-darwin.zip"
$ unzip wasi-vfs-cli-aarch64-apple-darwin.zip

# For x86_64 Linux host machine
$ curl -LO "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v${WASI_VFS_VERSION}/wasi-vfs-cli-x86_64-unknown-linux-gnu.zip"
$ unzip wasi-vfs-cli-x86_64-unknown-linux-gnu.zip

# See release page for more platforms: https://github.com/kateinoigakukun/wasi-vfs/releases

$ mv wasi-vfs /usr/local/bin/wasi-vfs
```

Install the gem and add to the application's Gemfile by executing:

    $ bundle add scarpe-wasm

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install scarpe-wasm

## Usage: Running a Shoes App

Wasm doesn't work quite like Shoes Classic. Instead, the various Ruby libraries are compiled to WebAssembly code to be run by your browser. As a result, running an application is a little bit different.

In development you can run a Shoes app from the command line:

```bash
$ exe/scarpe-wasm --dev button_alert.rb
```

This will build a default Wasm package for the Scarpe libraries but no additional gems, and then start a web server running your application with that default package. It will also open a Google Chrome tab pointed at that server.

## Usage: Packaging a Wasm App

Scarpe-Wasm allows you to package an application into packed Wasm code and an HTML loading page. Note that this won't work with gems that use native extensions - we can't easily translate them into WebAssembly.

To run a Shoes app via Scarpe-Wasm you'll need to create a script directory and install everything locally. We'll use button_alert.rb as an example.

``` bash
$ mkdir button_alert_app
$ cd button_alert_app

$ vi Gemfile
===
source "https://rubygems.org"

# These gems can be installed at a path or git branch if you're doing development.
# Remember that lacci should also be specified if you're modifying it.
gem "scarpe-components"
gem "scarpe-wasm"
gem "wasify"
===
$ bundle

$ mkdir src
$ cp ~/button_alert.rb src/  # Copy your app from wherever you have it
$ vi src/button_alert.rb
===
require "scarpe-wasm" # currently need to add this in front of the source file
===
$ bundle
$ bundle exec wasify src/button_alert.rb
$ ls # should see index.html and packed_ruby.wasm
Gemfile         index.html      src
Gemfile.lock        packed_ruby.wasm
$ ruby -run -e httpd . -p 8080  # must be port 8080 specifically
```

Then connect to localhost:8080 using your browser! The Wasm-based Scarpe app will run.

Please see "Installation" for more details about installing Scarpe-Wasm and the wasi-vfs library it depends on.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scarpe-wasm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/scarpe-wasm/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Scarpe::Wasm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/scarpe-wasm/blob/main/CODE_OF_CONDUCT.md).
