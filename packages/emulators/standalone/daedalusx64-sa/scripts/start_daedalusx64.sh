#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 daedalus"

#Check if DaedalusX64 exists in .config
if [ ! -d "/storage/.config/DaedalusX64" ]; then
  cp -r "/usr/config/DaedalusX64" "/storage/.config/"
fi

#Check if n64 save state folders exist
if [ ! -d "/storage/roms/savestates/n64/daedalus" ]; then
    mkdir -p "/storage/roms/savestates/n64/daedalus"
fi

# Link Roms, Saves, and SaveStates to correct dir
rm "/storage/.config/DaedalusX64/Roms"
ln -sf "/storage/roms/n64" "/storage/.config/DaedalusX64/Roms"
rm "/storage/.config/DaedalusX64/SavesGames"
ln -sf "/storage/roms/n64" "/storage/.config/DaedalusX64/SavesGames"
rm "/storage/.config/DaedalusX64/SaveStates"
ln -sf "/storage/roms/savestates/n64/daedalus" "/storage/.config/DaedalusX64/SaveStates"

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

#Always grab the latest daedalus bin
shasum1=$(sha1sum /usr/config/DaedalusX64/daedalus | awk '{print $1}')
shasum2=$(sha1sum /storage/.config/DaedalusX64/daedalus | awk '{print $1}')

if [ "$shasum1" <> "$shasum2" ]; then
  cp -r "/usr/config/DaedalusX64/daedalus" "/storage/.config/DaedalusX64/daedalus"
fi

cd /storage/.config/DaedalusX64/

${EMUPERF} /storage/.config/DaedalusX64/daedalus "${1}"
