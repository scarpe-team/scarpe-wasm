FROM ubuntu:20.04

# This is needed in webview to prevent some dependencies from asking for user input for timezones and stuff. not sure about here but keeping it.
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y curl unzip git autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

# Install asdf
RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf

ENV PATH="$PATH:/root/.asdf/bin:/root/.asdf/shims"

# Install Ruby
RUN asdf plugin add ruby && \
    asdf install ruby 3.2.0 && \
    asdf global ruby 3.2.0

# Download and install wasi-vfs
RUN curl -LO "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v0.1.1/wasi-vfs-cli-x86_64-unknown-linux-gnu.zip" && \
    unzip wasi-vfs-cli-x86_64-unknown-linux-gnu.zip && \
    mv wasi-vfs /usr/local/bin/wasi-vfs && \
    rm wasi-vfs-cli-x86_64-unknown-linux-gnu.zip

# Set the working directory
WORKDIR /scarpe-wasm

COPY . /scarpe-wasm

# Install gems
RUN bundle install

