FROM gisops/prime_server:latest
MAINTAINER Julian Psotta <julian@gis-ops.com>

# Set docker specific settings
ENV TERM xterm
RUN export DEBIAN_FRONTEND=noninteractive

# Set ENV Variablese
RUN apt-get update && apt-get install -y -q --no-install-recommends apt-transport-https build-essential \
                                                                    ca-certificates curl git libssl-dev wget

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.15.0

# Replace shell with bash, so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR ${NVM_DIR}

# Copy the script
COPY build_node.sh ./

# Run Node installer
RUN /bin/bash build_node.sh ${NVM_DIR} ${NODE_VERSION}

# Add to path
ENV NODE_PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/lib/node_modules
ENV PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:$PATH
