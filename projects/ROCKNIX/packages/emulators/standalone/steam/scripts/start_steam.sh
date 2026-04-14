#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 FEX"

if [ ! -d "/storage/.config/fex-emu" ]; then
    cp -r "/usr/config/fex-emu" "/storage/.config/"
fi

mkdir -p /storage/roms/steam/steamapps
VDF="/storage/.local/share/Steam/steamapps/libraryfolders.vdf"
if [  -f $VDF ]; then
    grep -q '"/storage/roms/steam"' "$VDF" || sed -i '$ s/}/\t"1" {"path" "\/storage\/roms\/steam"}\n}/' "$VDF"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASOUND_LIB=$(get_setting asound_host_library "${PLATFORM}" "${GAME}")
DRM_LIB=$(get_setting drm_host_library "${PLATFORM}" "${GAME}")
VULKAN_LIB=$(get_setting vulkan_host_library "${PLATFORM}" "${GAME}")
WAYLAND_LIB=$(get_setting wayland_client_host_library "${PLATFORM}" "${GAME}")
GL_LIB=$(get_setting gl_host_library "${PLATFORM}" "${GAME}")

TMP=$(mktemp)

jq \
  --arg asound "$ASOUND_LIB" \
  --arg drm "$DRM_LIB" \
  --arg vulkan "$VULKAN_LIB" \
  --arg wayland "$WAYLAND_LIB" \
  --arg gl "$GL_LIB" \
  '.ThunksDB |= {
    asound: ($asound | tonumber),
    drm: ($drm | tonumber),
    Vulkan: ($vulkan | tonumber),
    WaylandClient: ($wayland | tonumber),
    GL: ($gl | tonumber)
  }' \
  /storage/.config/fex-emu/Config.json > "$TMP" \
  && mv "$TMP" /storage/.config/fex-emu/Config.json

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

export GSK_RENDERER=gl

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "ASOUND HOST LIB set to: ${ASOUND_LIB}"
  echo "DRM HOST LIB set to: ${DRM_LIB}"
  echo "VULKAN HOST LIB set to: ${VULKAN_LIB}"
  echo "WAYLAND HOST LIB set to: ${WAYLAND_LIB}"
  echo "GL HOST LIB set to: ${GL_LIB}"
  echo "VSYNC set to: ${VSYNC}"

systemctl stop systemd-binfmt
if [[ "$1" == *.desktop && -f "$1" && "$(basename "$1")" != "Steam.desktop" ]]; then
    EXEC_LINE=$(grep -m1 '^Exec=' "$1" | cut -d'=' -f2-)
    GAME_URI="${EXEC_LINE#steam }"
    ${EMUPERF} FEX /usr/bin/steam -bigpicture "$GAME_URI"
else
    ${EMUPERF} FEX /usr/bin/steam -bigpicture
fi
systemctl start systemd-binfmt
