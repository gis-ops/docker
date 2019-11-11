FROM ubuntu:18.04
MAINTAINER Julian Psotta <julian@gis-ops.com>

# Set docker specific settings
ENV TERM xterm
RUN export DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Install deps
RUN apt-get update && apt-get update --fix-missing && apt-get install -y cmake build-essential autoconf pkg-config \
                                                                         libcurl4-openssl-dev git libczmq-dev libzmq5 \
                                                                         libtool

# Build chain
COPY build_prime_server.sh ./
ARG version
RUN /bin/bash build_prime_server.sh $version

# Clean
WORKDIR /
RUN rm -rf ./build_prime_server.sh ./prime_server
