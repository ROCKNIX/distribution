#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "dolphin-emu"

# Dolphin writes its shader and pipeline caches here but will not create the
# directory itself. Games can be launched from the Qt game list too.
mkdir -p "/storage/.cache/dolphin-emu"

#Retroachievements
/usr/bin/cheevos_dolphin.sh

# Bind to the controller SDL reports for this hardware, the same way the game
# launchers do. Without this the profiles keep their @SDL_DEVICE@ placeholder
# and nothing binds, so the settings UI would have no working input.
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls
CONF_DIR="/storage/.config/dolphin-emu"
# SDL names a gamepad after the mapping it resolves, not the joystick name
# control-gen reports, so resolve it from the database by GUID. The CRC in
# bytes 5-8 is ignored: SDL3 stores one there, SDL2 leaves it zeroed.
SDL_DB="${SDL_GAMECONTROLLERCONFIG_FILE:-/storage/.config/gptokeyb/gamecontrollerdb.txt}"
SDL_DEVICE="${param_device}"
if [ -n "${DEVICE}" ] && [ -f "${SDL_DB}" ]; then
  GUID_KEY="$(echo "${DEVICE}" | cut -c1-4)0000$(echo "${DEVICE}" | cut -c9-)"
  MAPLINE="$(awk -F, -v d="${DEVICE}" -v k="${GUID_KEY}" '!/^#/ && NF>1 {
      if ($1 == d) { exact = $0; exit }
      if (loose == "" && substr($1,5,4) == "0000") {
        g = substr($1,1,4) "0000" substr($1,9)
        if (g == k) { loose = $0 }
      }
    }
    END { print (exact != "" ? exact : loose) }' "${SDL_DB}")"
  MAPPED="$(echo "${MAPLINE}" | cut -d, -f2)"
  [ -n "${MAPPED}" ] && SDL_DEVICE="${MAPPED}"
fi
for CFG in "${CONF_DIR}/Hotkeys.ini" "${CONF_DIR}/GCPadNew.ini" "${CONF_DIR}/WiimoteNew.ini"; do
  [ -f "${CFG}" ] && sed -i "/^Device = /c\\Device = SDL/0/${SDL_DEVICE}" "${CFG}"
done

export QT_QPA_PLATFORM=wayland

# 'class' is an XWayland-only criteria; sway reports app_id for native Wayland clients.
# Match on the process instead so this works whichever platform plugin is in use.
sway_fullscreen "dolphin-emu" "pidof" &

/usr/bin/dolphin-emu >/dev/null 2>&1
