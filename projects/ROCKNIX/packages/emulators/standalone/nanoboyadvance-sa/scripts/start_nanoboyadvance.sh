#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 NanoBoyAdvance"

#Check if nanoboyadvance exists in .config
if [ ! -d "/storage/.config/nanoboyadvance" ]; then
    mkdir -p "/storage/.config/nanoboyadvance"
        cp -r "/usr/config/nanoboyadvance" "/storage/.config/"
fi

#Make nanoboyadvance bios folder
if [ ! -d "/storage/roms/bios/gba" ]; then
    mkdir -p "/storage/roms/bios/gba"
fi

#Copy open source bios if no other bios exists
if [ ! -f "/storage/roms/bios/gba/gba_bios.bin" ]; then
  cp -r "/usr/config/nanoboyadvance" "/storage/roms/bios/gba/gba_bios.bin"
fi

#Set the cores to use
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
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

#Run nanoboyadvance emulator
${EMUPERF} /usr/bin/NanoBoyAdvance "${1}"
