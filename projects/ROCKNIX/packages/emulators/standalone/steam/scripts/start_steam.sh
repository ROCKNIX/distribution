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
  LSFG_ENABLE=$(get_setting lsfg_enable "${PLATFORM}" "${GAME}")
  LSFG_ENABLE=${LSFG_ENABLE:-0}
  LSFG_MULTIPLIER=$(get_setting lsfg_multiplier "${PLATFORM}" "${GAME}")
  LSFG_MULTIPLIER=${LSFG_MULTIPLIER:-2}
  LSFG_FLOW_SCALE=$(get_setting lsfg_flow_scale "${PLATFORM}" "${GAME}")
  LSFG_FLOW_SCALE=${LSFG_FLOW_SCALE:-0.30}
  LSFG_PERFORMANCE_MODE=$(get_setting lsfg_performance_mode "${PLATFORM}" "${GAME}")
  LSFG_PERFORMANCE_MODE=${LSFG_PERFORMANCE_MODE:-1}
  FPS_LIMIT=$(get_setting fps_limit "${PLATFORM}" "${GAME}")
  FPS_LIMIT=${FPS_LIMIT:-0}
}

steam_apply_fps_limit() {
  if [ "${FPS_LIMIT}" != "0" ]; then
    export DXVK_CONFIG="dxgi.maxFrameRate = ${FPS_LIMIT}"
    export VKD3D_FRAME_RATE=${FPS_LIMIT}
  fi
}

steam_apply_lsfg_settings() {
  if [ "${LSFG_ENABLE}" = "1" ]; then
    unset DISABLE_LSFGVK
    export LSFGVK_ENV=1
    export LSFGVK_DLL_PATH="/storage/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll"
    export LSFGVK_MULTIPLIER="${LSFG_MULTIPLIER}"
    export LSFGVK_FLOW_SCALE="${LSFG_FLOW_SCALE}"
    export LSFGVK_PERFORMANCE_MODE="${LSFG_PERFORMANCE_MODE}"
    export ENABLE_GAMESCOPE_WSI=0
  else
    export DISABLE_LSFGVK=1
  fi
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
  echo "LSFG ENABLE set to: ${LSFG_ENABLE}"
  echo "LSFG MULTIPLIER set to: ${LSFG_MULTIPLIER}"
  echo "LSFG FLOW SCALE set to: ${LSFG_FLOW_SCALE}"
  echo "LSFG PERFORMANCE MODE set to: ${LSFG_PERFORMANCE_MODE}"
  echo "LSFG FPS LIMIT set to: ${FPS_LIMIT}"
  echo "VSYNC set to: ${VSYNC}"
}

steam_read_sway_geometry() {
  eval "$(swaymsg -t get_outputs | jq -r '
    .[] | select(.focused == true) |
    "W=\(.current_mode.width) H=\(.current_mode.height) TRANSFORM=\(.transform) REFRESH=\(.current_mode.refresh // 60000)"
  ')"
  # Round to nearest (119990 mHz -> 120) to match the mode's integer vrefresh,
  # which gamescope's -r must hit exactly or it falls back to the preferred mode.
  REFRESH_HZ=$(((REFRESH + 500) / 1000))
}

steam_setup_environment() {
  TZ=$(timedatectl status | grep 'Time zone' | awk '{print $3}')
  [ -n "${TZ}" ] && export TZ
}

steam_touch_calibration_begin() {
  local orientation="$1"
  local model=""
  local name_path

  STEAM_TOUCH_EVENT=""
  STEAM_TOUCH_RULE=""

  [ "${orientation}" = "upsidedown" ] || return 0
  if [ -r /proc/device-tree/model ]; then
    model=$(tr -d '\000' </proc/device-tree/model)
  fi
  [ "${model}" = "AYANEO Pocket S Mini" ] || return 0

  for name_path in /sys/class/input/event*/device/name; do
    if [ "$(cat "${name_path}" 2>/dev/null)" = "Hynitron CST66xx Touchscreen" ]; then
      STEAM_TOUCH_EVENT="${name_path%/device/name}"
      break
    fi
  done
  [ -n "${STEAM_TOUCH_EVENT}" ] || return 0

  STEAM_TOUCH_RULE="/run/udev/rules.d/99-steam-touch-calibration.rules"
  mkdir -p "${STEAM_TOUCH_RULE%/*}"
  printf '%s\n' \
    'ACTION!="remove", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Hynitron CST66xx Touchscreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1"' \
    >"${STEAM_TOUCH_RULE}"
  udevadm control --reload
  udevadm trigger --action=change "${STEAM_TOUCH_EVENT}"
  udevadm settle --timeout=3 >/dev/null 2>&1 || true
}

steam_touch_calibration_end() {
  [ -n "${STEAM_TOUCH_RULE:-}" ] || return 0

  rm -f "${STEAM_TOUCH_RULE}"
  udevadm control --reload >/dev/null 2>&1 || true
  if [ -n "${STEAM_TOUCH_EVENT:-}" ]; then
    udevadm trigger --action=change "${STEAM_TOUCH_EVENT}" \
      >/dev/null 2>&1 || true
  fi
  STEAM_TOUCH_RULE=""
  STEAM_TOUCH_EVENT=""
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
      -E TZ="$TZ" \
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
  echo 0 >/proc/sys/fs/binfmt_misc/x86
  echo 0 > /proc/sys/fs/binfmt_misc/box32
  echo 0 > /proc/sys/fs/binfmt_misc/box64
  rm "/storage/.local/share/Steam/compatibilitytools.d/compatibilitytool.vdf"
}

steam_launch_bigpicture() {
  local game_uri=""
  local force_orientation="normal"
  local gamescope_mode_file="/storage/.config/gamescope/modes.cfg"
  local steam_exit_code=0
  local gamescope_exit_code=0
  local steam_exit_code_file=""
  if [ "${TRANSFORM}" = "90" ]; then
    force_orientation="right"
  elif [ "${TRANSFORM}" = "180" ]; then
    force_orientation="upsidedown"
  elif [ "${TRANSFORM}" = "270" ]; then
    force_orientation="left"
  fi

  if [[ "$1" == *.desktop && -f "$1" && "$(basename "$1")" != "Steam.desktop" ]]; then
    local exec_line
    exec_line=$(grep -m1 '^Exec=' "$1" | cut -d'=' -f2-)
    game_uri="${exec_line#steam } -silent"
  fi

  mkdir -p "$(dirname "$gamescope_mode_file")"
  touch "$gamescope_mode_file"
  unset MESA_LOADER_DRIVER_OVERRIDE
  if [ "${STEAM_FLAVOR}" = "arm64" ]; then
    export STEAM_COMPAT_GRAPHICS_PROVIDER=//storage/.local/share/fex-emu/RootFS/ArchLinux/graphics_provider.json
    steam_exit_code_file=$(mktemp /tmp/steam-exit-code.XXXXXX)
    systemctl stop sway
    steam_touch_calibration_begin "${force_orientation}"
    trap steam_touch_calibration_end EXIT
    while true; do
      rm -f "${steam_exit_code_file}"
      GAMESCOPE_MODE_SAVE_FILE="${gamescope_mode_file}" GAMESCOPE_FAKE_OUTPUT_MM=508x286 \
      env -u WAYLAND_DISPLAY LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ ${EMUPERF} \
      gamescope $PREFER_OUTPUT -W "$W" -H "$H" -r "$REFRESH_HZ" --xwayland-count 2 --mangoapp --backend drm --force-orientation "${force_orientation}" -e -- \
      /bin/bash -c '
        exit_file="$1"
        shift
        "$@"
        printf "%s\n" "$?" >"${exit_file}"
      ' _ "${steam_exit_code_file}" \
      /storage/.local/share/Steam/steamrtarm64/steam -deckard -steamos3 -gamepadui -noshaders ${game_uri:+"$game_uri"}
      gamescope_exit_code=$?
      if [ -f "${steam_exit_code_file}" ]; then
        steam_exit_code=$(cat "${steam_exit_code_file}")
      else
        steam_exit_code=${gamescope_exit_code}
      fi
      [ "${steam_exit_code}" = "42" ] || break
    done
    rm -f "${steam_exit_code_file}"
    steam_touch_calibration_end
    trap - EXIT
    systemctl start essway
    exit 0
  else
    FEX /usr/bin/steam -exitsteam
    systemctl stop sway
    steam_touch_calibration_begin "${force_orientation}"
    trap steam_touch_calibration_end EXIT
    GAMESCOPE_MODE_SAVE_FILE="${gamescope_mode_file}" GAMESCOPE_FAKE_OUTPUT_MM=508x286 env -u WAYLAND_DISPLAY ${EMUPERF} \
      gamescope $PREFER_OUTPUT -W "$W" -H "$H" -r "$REFRESH_HZ" --xwayland-count 2 --backend drm --force-orientation "${force_orientation}" -- \
      FEX /usr/bin/steam -nobigpicture -noverifyfiles -nobootstrapupdate -skipinitialbootstrap -norepairfiles -noshaders ${game_uri:+"$game_uri"}
    steam_touch_calibration_end
    trap - EXIT
    systemctl start essway
    exit 0
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
