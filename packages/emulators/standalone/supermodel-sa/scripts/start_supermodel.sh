#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

# Source predefined functions and variables
. /etc/profile
set_kill set "-9 supermodel"

CONFIG_DIR="/storage/.config/supermodel"
SOURCE_DIR="/usr/config/supermodel"

#Check if supermodel exists in .config
if [ ! -d "${CONFIG_DIR}" ]; then
    mkdir -p "${CONFIG_DIR}"
        cp -r "${SOURCE_DIR}" "/storage/.config/"
fi

if [ ! -d "${CONFIG_DIR}/NVRAM" ]; then
    mkdir -p "${CONFIG_DIR}/NVRAM"
fi

if [ ! -d "${CONFIG_DIR}/Saves" ]; then
    mkdir -p "${CONFIG_DIR}/Saves"
fi

if [ ! -d "${CONFIG_DIR}/LocalConfig" ]; then
    mkdir -p "${CONFIG_DIR}/LocalConfig"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
RESOLUTION=$(get_setting resolution "${PLATFORM}" "${GAME}")
ENGINE=$(get_setting rendering_engine "${PLATFORM}" "${GAME}")

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

OPTIONS=" -fullscreen"

#VSYNC
if [ "$VSYNC" = "true" ]
then
  OPTIONS+=" -vsync"
elif [ "$VSYNC" = "false" ]
then
  OPTIONS+=" -no-vsync"
fi

#ENGINE
if [ "$ENGINE" = "1" ]
then
  OPTIONS+=" -new3d"
elif [ "$ENGINE" = "0" ]
then
  OPTIONS+=" -legacy3d"
fi

#RESOLUTION
if [ "$RESOLUTION" = "0" ]
then
  OPTIONS+=" -res=1920,1080"
elif [ "$RESOLUTION" = "1" ]
then
  OPTIONS+=" -res=496,384"
elif [ "$RESOLUTION" = "2" ]
then
  OPTIONS+=" -res=992,768"
fi

sway_fullscreen supermodel &

cd ${CONFIG_DIR}
echo "Command: supermodel ${1} ${OPTIONS}" >/var/log/exec.log 2>&1
${EMUPERF} supermodel "${1}" "${OPTIONS}" >>/var/log/exec.log 2>&1 ||:
