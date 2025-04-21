#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

set_kill set "-9 drastic"

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

if echo "${UI_SERVICE}" | grep "sway"; then
    /usr/bin/drastic_sense.sh &
fi

cd /storage/.config/drastic/
@HOTKEY@

# Fix for libmali gpu driver on S922X platform
if [ "${HW_DEVICE}" = "S922X" ]; then
  GPUDRIVER=$(/usr/bin/gpudriver)

  if [ "${GPUDRIVER}" = "libmali" ]; then
    export SDL_VIDEO_GL_DRIVER=\/usr\/lib\/egl\/libGL.so.1
    export SDL_VIDEO_EGL_DRIVER=\/usr\/lib\/egl\/libEGL.so.1
  fi
fi

$GPTOKEYB "drastic" -c "drastic.gptk" &
./drastic "$1"
kill -9 $(pidof gptokeyb)

if echo "${UI_SERVICE}" | grep "sway"; then
    kill -9 $(pidof drastic_sense.sh)
fi
