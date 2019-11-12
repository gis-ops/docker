# Install nvm/npm/nodejs
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && . "${1}"/nvm.sh &&
  nvm install "${2}" && nvm alias default "${2}" && nvm use default

# Link mising headers for Valhalla
ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/node.h /usr/include/node.h
ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/uv.h /usr/include/uv.h
ln -s /usr/local/nvm/versions/node/v10.15.0/include/node/v8.h /usr/include/v8.h
