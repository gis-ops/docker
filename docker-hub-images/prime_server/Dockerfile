FROM ubuntu:18.04
MAINTAINER Julian Psotta <julian@gis-ops.com>

# Set docker specific settings
ENV TERM xterm
RUN export DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt-get update
RUN apt-get update --fix-missing
RUN apt-get install -y cmake build-essential autoconf pkg-config libcurl4-openssl-dev git libczmq-dev libzmq5 libtool

# Build chain
ARG version
RUN git clone https://github.com/kevinkreiser/prime_server.git
WORKDIR /prime_server
RUN git fetch && git fetch --tags
RUN git checkout $version
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure --prefix=/usr LIBS="-lpthread"
RUN make all -j
RUN make -k test -j
RUN make install
