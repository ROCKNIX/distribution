#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 SkyEmu"

#Check if SkyEmu dir exists in .config
if [ ! -d "/storage/.config/SkyEmu" ]; then
  cp -rf "/usr/config/SkyEmu" "/storage/.config/"
fi

#Check if SkyEmu savestate dir exists in .config
if [ ! -d "/storage/roms/savestates/SkyEmu" ]; then
  mkdir "/storage/roms/savestates/SkyEmu"
fi

# Link  .config/dolphin-emu to .local
rm -rf /storage/.local/share/Sky/SkyEmu
ln -sf /storage/.config/SkyEmu /storage/.local/share/Sky/SkyEmu

# Retroachievements
/usr/bin/cheevos_skyemu.sh

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
  ### All..
  unset EMUPERF
fi

${EMUPERF} /usr/bin/SkyEmu "${1}"
