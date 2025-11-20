#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 bigpemu"

#Check if bigpemu exists in .config
if [ ! -d "/storage/.config/bigpemu/userdata" ]; then
  mkdir -p "/storage/.config/bigpemu/userdata"
  cp -r "/usr/config/bigpemu/userdata" "/storage/.config/bigpemu"
fi

# Link bigpemu userdata to .config/bigemu
rm -r /storage/.bigpemu_userdata
ln -sf /storage/.config/bigpemu/userdata /storage/.bigpemu_userdata

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  #All..
  unset EMUPERF
fi

${EMUPERF} /usr/share/bigpemu/bigpemu "${1}"
