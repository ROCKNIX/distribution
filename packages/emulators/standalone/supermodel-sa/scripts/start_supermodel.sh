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

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${ROMNAME##*/}")
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

cd ${CONFIG_DIR}
echo "Command: supermodel "${1}" -fullscreen" >/var/log/exec.log 2>&1
${EMUPERF} supermodel "${1}" -fullscreen >>/var/log/exec.log 2>&1 ||: