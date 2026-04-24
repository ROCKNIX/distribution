#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 gamescope steam FEX"

mkdir -p /storage/roms/steam/steamapps
VDF="/storage/.local/share/Steam/steamapps/libraryfolders.vdf"
if [  -f $VDF ]; then
    grep -q '"/storage/roms/steam"' "$VDF" || sed -i '$ s/}/\t"1" {"path" "\/storage\/roms\/steam"}\n}/' "$VDF"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASOUND_LIB=$(get_setting asound_host_library "${PLATFORM}" "${GAME}"); ASOUND_LIB=${ASOUND_LIB:-0}
DRM_LIB=$(get_setting drm_host_library "${PLATFORM}" "${GAME}"); DRM_LIB=${DRM_LIB:-0}
VULKAN_LIB=$(get_setting vulkan_host_library "${PLATFORM}" "${GAME}"); VULKAN_LIB=${VULKAN_LIB:-0}
WAYLAND_LIB=$(get_setting wayland_client_host_library "${PLATFORM}" "${GAME}"); WAYLAND_LIB=${WAYLAND_LIB:-0}
GL_LIB=$(get_setting gl_host_library "${PLATFORM}" "${GAME}"); GL_LIB=${GL_LIB:-0}
GAMESCOPE=$(get_setting gamescope "${PLATFORM}" "${GAME}")

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

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "GAMESCOPE set to: ${GAMESCOPE}"

echo 0 > /proc/sys/fs/binfmt_misc/x86_64
echo 0 > /proc/sys/fs/binfmt_misc/x86
mkdir -p "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
cp -f "/usr/share/steam/toolmanifest.vdf" "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"

eval $(swaymsg -t get_outputs | jq -r '
  .[] | select(.focused == true) |
  "W=\(.current_mode.width) H=\(.current_mode.height) TRANSFORM=\(.transform) REFRESH=\(.current_mode.refresh // 60000)"
')
REFRESH_HZ=$((REFRESH / 1000))
if [[ "$TRANSFORM" == "90" || "$TRANSFORM" == "270" || "$TRANSFORM" == "flipped-90" || "$TRANSFORM" == "flipped-270" ]]; then
  WIDTH=$H
  HEIGHT=$W
else
  WIDTH=$W
  HEIGHT=$H
fi

if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback true'
fi
if [[ "$1" == *.desktop && -f "$1" && "$(basename "$1")" != "Steam.desktop" ]]; then
    EXEC_LINE=$(grep -m1 '^Exec=' "$1" | cut -d'=' -f2-)
    GAME_URI="${EXEC_LINE#steam }"
    if [ "${GAMESCOPE}" = "0" ]; then
        SDL_VIDEODRIVER=x11 LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} /storage/.local/share/Steam/steamrtarm64/steam -bigpicture "$GAME_URI"
    else
        LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} gamescope -w $WIDTH -h $HEIGHT -W $WIDTH -H $HEIGHT -r $REFRESH_HZ -b -e -- /storage/.local/share/Steam/steamrtarm64/steam -bigpicture "$GAME_URI"
    fi
else
    if [ "${GAMESCOPE}" = "0" ]; then
        SDL_VIDEODRIVER=x11 LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} /storage/.local/share/Steam/steamrtarm64/steam -bigpicture
    else
        LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} gamescope -w $WIDTH -h $HEIGHT -W $WIDTH -H $HEIGHT -r $REFRESH_HZ -b -e -- /storage/.local/share/Steam/steamrtarm64/steam -bigpicture
    fi
fi
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback false'
fi
systemctl restart systemd-binfmt

