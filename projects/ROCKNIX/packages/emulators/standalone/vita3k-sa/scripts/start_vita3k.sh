#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 Vita3K"

OUTPUT_PATH="/storage/.config/vita3k/launcher"
GAME="${1}"

#Check if vita3k folder exists in /storage/.config/vita3k
if [ ! -d "/storage/.config/vita3k" ]; then
    mkdir -p "/storage/.config/vita3k"
fi

#Make sure we sync any changes from /storage/.config so new features will be enabled
#without overwriting existing settings.
rsync -ah --update /usr/config/vita3k/* /storage/.config/vita3k 2>/dev/null

#Check if vita3k folder exists in /storage/roms/psvita
if [ ! -d "/storage/roms/psvita/vita3k" ]; then
    mkdir -p "/storage/roms/psvita/vita3k"
fi

if [ ! -d "/storage/psvita"]; then
   ln -sf /storage/roms/psvita /storage/psvita
else
   if [[ ! $(file /storage/psvita | grep "symbolic") ]]; then 
      rsync -ah --update /storage/psvita/* /storage/roms/psvita 2>/dev/null
      rm -rf /storage/psvita
      ln -sf /storage/roms/psvita /storage/psvita
   fi
fi

if [ -n "${GAME}" ]; then
  OPTIONS="-r $(cat "${GAME}")"
fi

#Start Vita3K
/usr/bin/Vita3K ${OPTIONS}