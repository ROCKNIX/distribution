#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 ares"

CONF_DIR="/storage/.config/ares"
ARES_INI="settings.bml"

# Check if ares exists in .config
if [ ! -d "${CONF_DIR}" ]; then
        cp -r "/usr/config/ares" "/storage/.config/"
fi

# Link  .config/ares to .local
rm -rf /storage/.local/share/ares
ln -sf /storage/.config/ares /storage/.local/share/ares

# Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")

# Set the cores to use
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

${EMUPERF} /usr/bin/ares --fullscreen "${1}"
