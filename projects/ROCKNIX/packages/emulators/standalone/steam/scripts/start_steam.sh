#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

steam_ensure_fex_config_template() {
  if [ ! -d "/storage/.config/fex-emu" ]; then
    cp -r "/usr/config/fex-emu" "/storage/.config/"
  fi
}

steam_prepare_storage_and_vdf() {
  mkdir -p /storage/roms/steam/steamapps
  local vdf="/storage/.local/share/Steam/steamapps/libraryfolders.vdf"
  if [ -f "$vdf" ]; then
    grep -q '"/storage/roms/steam"' "$vdf" || sed -i '$ s/}/\t"1" {"path" "\/storage\/roms\/steam"}\n}/' "$vdf"
  fi
}

steam_load_es_thunk_settings() {
  GAME=$(echo "${1}" | sed "s#^/.*/##")
  PLATFORM=$(echo "${2}" | sed "s#^/.*/##")
  ASOUND_LIB=$(get_setting asound_host_library "${PLATFORM}" "${GAME}")
  ASOUND_LIB=${ASOUND_LIB:-0}
  DRM_LIB=$(get_setting drm_host_library "${PLATFORM}" "${GAME}")
  DRM_LIB=${DRM_LIB:-0}
  VULKAN_LIB=$(get_setting vulkan_host_library "${PLATFORM}" "${GAME}")
  VULKAN_LIB=${VULKAN_LIB:-0}
  WAYLAND_LIB=$(get_setting wayland_client_host_library "${PLATFORM}" "${GAME}")
  WAYLAND_LIB=${WAYLAND_LIB:-0}
  GL_LIB=$(get_setting gl_host_library "${PLATFORM}" "${GAME}")
  GL_LIB=${GL_LIB:-0}
  GAMESCOPE=$(get_setting gamescope "${PLATFORM}" "${GAME}")
}

steam_write_fex_config_json() {
  local tmp
  tmp=$(mktemp)
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
    /storage/.config/fex-emu/Config.json >"$tmp" &&
    mv "$tmp" /storage/.config/fex-emu/Config.json
}

steam_set_cpu_affinity() {
  local cores
  cores=$(get_setting "cores" "${PLATFORM}" "${GAME}")
  if [ "${cores}" = "little" ]; then
    EMUPERF="${SLOW_CORES}"
  elif [ "${cores}" = "big" ]; then
    EMUPERF="${FAST_CORES}"
  else
    unset EMUPERF
  fi
}

steam_debug_print() {
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "ASOUND HOST LIB set to: ${ASOUND_LIB}"
  echo "DRM HOST LIB set to: ${DRM_LIB}"
  echo "VULKAN HOST LIB set to: ${VULKAN_LIB}"
  echo "WAYLAND HOST LIB set to: ${WAYLAND_LIB}"
  echo "GL HOST LIB set to: ${GL_LIB}"
  echo "GAMESCOPE set to: ${GAMESCOPE}"
  echo "VSYNC set to: ${VSYNC}"
}

steam_read_sway_geometry() {
  eval "$(swaymsg -t get_outputs | jq -r '
    .[] | select(.focused == true) |
    "W=\(.current_mode.width) H=\(.current_mode.height) TRANSFORM=\(.transform) REFRESH=\(.current_mode.refresh // 60000)"
  ')"
  REFRESH_HZ=$((REFRESH / 1000))
}

steam_scope_reexec_if_needed() {
  if [ -z "$_STEAM_SCOPE" ]; then
    systemctl stop steam-bigpicture.scope 2>/dev/null || true
    exec systemd-run \
      --scope \
      --slice=system.slice \
      --unit=steam-bigpicture \
      --collect \
      -E _STEAM_SCOPE=1 \
      -E HOME="$HOME" \
      -E USER="$USER" \
      -- "${STEAM_MAIN_SCRIPT}" "$@"
  fi
}

steam_dual_screen_begin() {
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback true'
    PREFER_OUTPUT="--prefer-output $SDL_VIDEO_DISPLAY_PRIORITY"
  fi
}

steam_dual_screen_end() {
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback false'
  fi
}

steam_arm64_binfmt_and_proton_prep() {
  echo 0 >/proc/sys/fs/binfmt_misc/x86_64
  echo 0 >/proc/sys/fs/binfmt_misc/x86
  mkdir -p "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
  cp -f "/usr/share/steam/toolmanifest.vdf" "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
}

steam_launch_bigpicture() {
  local game_uri=""
  if [[ "$1" == *.desktop && -f "$1" && "$(basename "$1")" != "Steam.desktop" ]]; then
    local exec_line
    exec_line=$(grep -m1 '^Exec=' "$1" | cut -d'=' -f2-)
    game_uri="${exec_line#steam }"
  fi

  if [ "${STEAM_FLAVOR}" = "arm64" ]; then
    if [ "${GAMESCOPE}" = "0" ]; then
      SDL_VIDEODRIVER=x11 LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} /storage/.local/share/Steam/steamrtarm64/steam -bigpicture ${game_uri:+"$game_uri"}
    else
      systemctl stop sway
      env -u WAYLAND_DISPLAY LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} \
        gamescope $PREFER_OUTPUT -W "$W" -H "$H" -r "$REFRESH_HZ" --xwayland-count 2 --backend drm --use-rotation-shader -b -e -- \
        /storage/.local/share/Steam/steamrtarm64/steam -bigpicture ${game_uri:+"$game_uri"}
      systemctl start essway
    fi
  else
    if [ "${GAMESCOPE}" = "0" ]; then
      ${EMUPERF} FEX /usr/bin/steam -bigpicture ${game_uri:+"$game_uri"}
    else
      systemctl stop sway
      env -u WAYLAND_DISPLAY ${EMUPERF} \
        gamescope $PREFER_OUTPUT -W "$W" -H "$H" -r "$REFRESH_HZ" --xwayland-count 2 --backend drm --use-rotation-shader -b -e -- \
        FEX /usr/bin/steam -bigpicture ${game_uri:+"$game_uri"}
      systemctl start essway
    fi
  fi
}

# Entry point from EmulationStation (not used when this file is sourced).
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source /etc/profile
  GAME=$(echo "${1}" | sed "s#^/.*/##")
  PLATFORM=$(echo "${2}" | sed "s#^/.*/##")
  STEAM_VERSION=$(get_setting steam_version "${PLATFORM}" "${GAME}")
  STEAM_VERSION=${STEAM_VERSION:-"arm64"}
  echo "STEAM_VERSION set to: ${STEAM_VERSION}"
  if [ "${STEAM_VERSION}" = "arm64" ]; then
    exec /usr/bin/start_steam_arm64.sh "$@"
  else
    exec /usr/bin/start_steam_x86.sh "$@"
  fi
fi
