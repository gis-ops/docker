FROM ubuntu:18.04
MAINTAINER Julian Psotta <julian@gis-ops.com>

# Mute Ubuntu
ENV TERM xterm
RUN export DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt-get update
RUN apt-get update --fix-missing
RUN apt-get install -y cmake build-essential autoconf pkg-config libcurl4-openssl-dev git libczmq-dev libzmq5 libtool


# <--- Build Prime_Server --->
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
WORKDIR /
RUN rm -rf /prime_server

# <--- Build NodeJS --->
# Set ENV Variablese
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.15.0

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
apt-transport-https \
build-essential \
ca-certificates \
curl \
git \
libssl-dev \
wget

WORKDIR ${NVM_DIR}

# Install nvm/npm/nodejs
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh  | bash
RUN . ${NVM_DIR}/nvm.sh \
&& nvm install ${NODE_VERSION} \
&& nvm alias default ${NODE_VERSION} \
&& nvm use default

# Link mising headers for Valhalla
RUN ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/node.h /usr/include/node.h
RUN ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/uv.h /usr/include/uv.h
RUN ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/v8.h /usr/include/v8.h

# Add to path
ENV NODE_PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/lib/node_modules
ENV PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:$PATH
