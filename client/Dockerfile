FROM docker.io/ubuntu:latest

# Install prerequisites
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update \
&& apt-get -qqy --no-install-recommends install \
  ca-certificates \
  git \
  sudo \
&& rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -d /build build \
&& mkdir /build \
&& chown build:build /build

# Configure sudo
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to non-root user
USER build

# Change to build directory
WORKDIR /build

# Get and install the code
RUN git clone https://github.com/acch/tinysync.git . \
&& /build/install.sh
