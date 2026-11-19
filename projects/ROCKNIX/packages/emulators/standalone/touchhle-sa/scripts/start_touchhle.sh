#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 touchHLE"

# Conf files vars
SOURCE_DIR="/usr/config/touchHLE"
CONF_DIR="/storage/.config/touchHLE"
TOUCHHLE_CONF="touchHLE_options.txt"

# Check if touchHLE exists in /storage/.config
if [ ! -d "${CONF_DIR}" ]; then
  cp -r "${SOURCE_DIR}" "/storage/.config/"
fi

# Check if touchHLE_options.txt exists in .config/touchHLE
if [ ! -f "${CONF_DIR}/${TOUCHHLE_CONF}" ]; then
  cp -r "${SOURCE_DIR}/${TOUCHHLE_CONF}" "${CONF_DIR}"
fi

# Check if touchHLE_wallpaper.* exists in .config/touchHLE
if ! compgen -G "${CONF_DIR}/touchHLE_wallpaper.*" > /dev/null; then
printf \
'\x89PNG\r\n\x1a\n'\
'\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde'\
'\x00\x00\x00\x0cIDAT\x08\xd7c\x60\x60\x60\x00\x00\x00\x04\x00\x01\xf6\x17\x38\x55'\
'\x00\x00\x00\x00IEND\xaeB`\x82' \
> "${CONF_DIR}/touchHLE_wallpaper.png"
fi

# Link roms/ios to touchHLE_apps
ln -snf "/storage/roms/ios" "${CONF_DIR}/touchHLE_apps"

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
DEVICE=$(get_setting device_type "${PLATFORM}" "${GAME}")
UPSCALE=$(get_setting upscale "${PLATFORM}" "${GAME}")

# Set device type
if [ "${DEVICE}" != "ipad" ]; then
  DEVICE="iphone"
fi

# Set upscaling
if [[ "${UPSCALE}" =~ ^[1-4]$ ]]; then
  UPSCALE="${UPSCALE}"
else
  UPSCALE=1
fi

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  ### All..
  unset EMUPERF
fi

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CONF DIR: ${CONF_DIR}/${GOPHER64_JSON}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "DEVICE TYPE set to: ${DEVICE}"
  echo "Launching /usr/bin/touchHLE --fullscreen=${DEVICE} ${1}"

# Start touchHLE
${EMUPERF} /usr/bin/touchHLE --fullscreen --scale-hack=${UPSCALE} --device-family=${DEVICE} "${1}"
