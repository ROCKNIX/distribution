#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

set_kill set "-9 drastic"

#Get game/platform info
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM="nds"

#Get ES feature settings
HIRES3D=$(get_setting hires_3d "${PLATFORM}" "${GAME}")
THREADED3D=$(get_setting threaded_3d "${PLATFORM}" "${GAME}")
FOLLOW3D=$(get_setting follow_3d_renderer "${PLATFORM}" "${GAME}")
MICTHRESH=$(get_setting microphone_sensitivity "${PLATFORM}" "${GAME}")

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

#Copy drastic files to .config
if [ ! -d "/storage/.config/drastic" ]; then
  mkdir -p /storage/.config/drastic/
  cp -r /usr/config/drastic/* /storage/.config/drastic/
fi

if [ ! -d "/storage/.config/drastic/system" ]; then
  mkdir -p /storage/.config/drastic/system
fi

for bios in nds_bios_arm9.bin nds_bios_arm7.bin
do
  if [ ! -e "/storage/.config/drastic/system/${bios}" ]; then
     if [ -e "/storage/roms/bios/${bios}" ]; then
       ln -sf /storage/roms/bios/${bios} /storage/.config/drastic/system
     fi
  fi
done

#Copy drastic files to .config
if [ ! -f "/storage/.config/drastic/drastic.gptk" ]; then
  cp -r /usr/config/drastic/drastic.gptk /storage/.config/drastic/
fi

#Make drastic savestate folder
if [ ! -d "/storage/roms/savestates/nds" ]; then
  mkdir -p /storage/roms/savestates/nds
fi

#Link savestates to roms/savestates/nds
rm -rf /storage/.config/drastic/savestates
ln -sf /storage/roms/savestates/nds /storage/.config/drastic/savestates

#Link saves to roms/nds/saves
rm -rf /storage/.config/drastic/backup
ln -sf /storage/roms/nds /storage/.config/drastic/backup

#Apply ES features to config
if [ "${HIRES3D}" = "1" ]; then
    sed -i 's/^hires_3d = .*/hires_3d = 1/' /storage/.config/drastic/config/drastic.cfg
else
    sed -i 's/^hires_3d = .*/hires_3d = 0/' /storage/.config/drastic/config/drastic.cfg
fi

if [ "${THREADED3D}" = "1" ]; then
    sed -i 's/^threaded_3d = .*/threaded_3d = 1/' /storage/.config/drastic/config/drastic.cfg
else
    sed -i 's/^threaded_3d = .*/threaded_3d = 0/' /storage/.config/drastic/config/drastic.cfg
fi

if [ "${FOLLOW3D}" = "1" ]; then
    sed -i 's/^fix_main_2d_screen = .*/fix_main_2d_screen = 1/' /storage/.config/drastic/config/drastic.cfg
else
    sed -i 's/^fix_main_2d_screen = .*/fix_main_2d_screen = 0/' /storage/.config/drastic/config/drastic.cfg
fi

cd /storage/.config/drastic/
@HOTKEY@

$GPTOKEYB "drastic" -c "drastic.gptk" &
# Fix actual touch inputs by replacing touch->mouse translation and add hw mic support
export LD_PRELOAD="/usr/lib/libdrastouch.so"
export SDL_TOUCH_MOUSE_EVENTS="0"
export DSHOOK_MIC_THRESH="${MICTHRESH}"
./drastic "$1"
kill -9 $(pidof gptokeyb)
