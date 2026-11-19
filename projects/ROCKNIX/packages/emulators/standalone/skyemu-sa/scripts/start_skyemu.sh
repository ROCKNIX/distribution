#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 SkyEmu"

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

#Check if SkyEmu dir exists in .config
if [ ! -d "/storage/.config/SkyEmu" ]; then
  cp -rf "/usr/config/SkyEmu" "/storage/.config/"
fi

#Check if SkyEmu savestate dir exists in .config
if [ ! -d "/storage/roms/savestates/SkyEmu" ]; then
  mkdir "/storage/roms/savestates/SkyEmu"
fi

#Make sure SkyEmu gptk config exists
if [ ! -f "/storage/.config/SkyEmu/SkyEmu.gptk" ]; then
  cp -r "/usr/config/SkyEmu/SkyEmu.gptk" "/storage/.config/SkyEmu/SkyEmu.gptk"
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

# Run SkyEmu
$GPTOKEYB "SkyEmu" -c "/storage/.config/SkyEmu/SkyEmu.gptk" &
${EMUPERF} /usr/bin/SkyEmu "${1}"
kill -9 "$(pidof gptokeyb)"
