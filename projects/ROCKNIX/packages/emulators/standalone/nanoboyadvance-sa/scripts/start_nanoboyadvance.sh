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

#Use the user's GBA BIOS, or the bundled open-source one
BIOS="/storage/roms/bios/gba_bios.bin"
[ -f "${BIOS}" ] || BIOS="/usr/config/nanoboyadvance/bios/gba_bios.bin"
sed -i "s|^bios_path = .*|bios_path = \"${BIOS}\"|" /storage/.config/nanoboyadvance/config.toml

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
