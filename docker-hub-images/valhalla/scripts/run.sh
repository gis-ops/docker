#!/usr/bin/env bash

CONFIG_PATH="/valhalla/conf"
CONFIG_FILE="${CONFIG_PATH}/valhalla.json"
SCRIPTS_PATH="/valhalla/scripts"
CUSTOM_FILES="/custom_files"
CUSTOM_CONFIG="${CUSTOM_FILES}/config"
CUSTOM_TILE_FILES="${CUSTOM_FILES}/tiles"

sh /valhalla/scripts/configure_valhalla.sh ${SCRIPTS_PATH} ${CONFIG_FILE} ${tile_urls} ${CUSTOM_TILE_FILES} ${min_x} ${max_x} ${min_y} ${max_y} ${build_elevation} ${build_admins} ${build_time_zones}

if test -f "${CUSTOM_CONFIG}/valhalla.json"; then
   echo "Found existing config file. Using it instead of a new one. Use at your own risk!";
   valhalla_service ${CUSTOM_CONFIG}/valhalla.json 1;
else
    echo "No custom config found. Using the regular config.";
    valhalla_service ${CONFIG_PATH}/valhalla.json 1;
fi

# Keep docker running easy
exec "$@";
