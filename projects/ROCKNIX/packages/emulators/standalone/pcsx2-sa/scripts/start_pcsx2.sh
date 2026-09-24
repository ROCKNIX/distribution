#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 pcsx2-qt"

CONF_DIR="/storage/.config/PCSX2"
CONF="${CONF_DIR}/inis/PCSX2.ini"
SECRETS="${CONF_DIR}/inis/secrets.ini"

if [ ! -f "${CONF}" ]; then
  mkdir -p "${CONF_DIR}"
  cp -r /usr/config/PCSX2/. "${CONF_DIR}"
fi
touch "${SECRETS}"
mkdir -p /storage/roms/bios/pcsx2/bios /storage/roms/savestates/ps2

# Set "key = value" in [section], adding the key or section when missing.
set_ini() {
  local file="${1}" section="\[${2}\]" key="${3}" value="${4}"
  if sed -n "\%^${section}%,\%^\[%p" "${file}" | grep -q "^${key} ="; then
    sed -i "\%^${section}%,\%^\[% s%^${key} =.*%${key} = ${value}%" "${file}"
  elif grep -q "^${section}" "${file}"; then
    sed -i "\%^${section}% a ${key} = ${value}" "${file}"
  else
    printf '\n[%s]\n%s = %s\n' "${2}" "${key}" "${value}" >>"${file}"
  fi
}

GAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM=$(echo "${2}" | sed "s#^/.*/##")

case "$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")" in
  0) set_ini "${CONF}" EmuCore/GS AspectRatio "4:3" ;;
  1) set_ini "${CONF}" EmuCore/GS AspectRatio "16:9" ;;
  2) set_ini "${CONF}" EmuCore/GS AspectRatio "Stretch" ;;
  *) set_ini "${CONF}" EmuCore/GS AspectRatio "Auto 4:3/3:2" ;;
esac

case "$(get_setting graphics_backend "${PLATFORM}" "${GAME}")" in
  1) set_ini "${CONF}" EmuCore/GS Renderer 12 ;;
  2) set_ini "${CONF}" EmuCore/GS Renderer 14 ;;
  3) set_ini "${CONF}" EmuCore/GS Renderer 13 ;;
  *) set_ini "${CONF}" EmuCore/GS Renderer -1 ;;
esac

FILTER=$(get_setting bilinear_filtering "${PLATFORM}" "${GAME}")
set_ini "${CONF}" EmuCore/GS filter "${FILTER:-2}"

IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
set_ini "${CONF}" EmuCore/GS upscale_multiplier "${IRES:-1}"

HWDOWNLOAD=$(get_setting hw_download_mode "${PLATFORM}" "${GAME}")
set_ini "${CONF}" EmuCore/GS HWDownloadMode "${HWDOWNLOAD:-0}"

[ "$(get_setting show_fps "${PLATFORM}" "${GAME}")" = "true" ] && FPS=true || FPS=false
set_ini "${CONF}" EmuCore/GS OsdShowFPS "${FPS}"

RATE=$(get_setting ee_cycle_rate "${PLATFORM}" "${GAME}")
set_ini "${CONF}" EmuCore/Speedhacks EECycleRate "$(( ${RATE:-3} - 3 ))"

SKIP=$(get_setting ee_cycle_skip "${PLATFORM}" "${GAME}")
set_ini "${CONF}" EmuCore/Speedhacks EECycleSkip "${SKIP:-0}"

[ "$(get_setting enable_widescreen_patches "${PLATFORM}" "${GAME}")" = "true" ] && WS=true || WS=false
set_ini "${CONF}" EmuCore EnableWideScreenPatches "${WS}"

# RetroAchievements
to_bool() { [ "${1}" = "1" ] && echo true || echo false; }
TOKEN=$(get_setting global.retroachievements.token)
if [ "$(get_setting global.retroachievements)" = "1" ] && [ -n "${TOKEN}" ]; then
  set_ini "${CONF}" Achievements Enabled true
  set_ini "${CONF}" Achievements Username "$(get_setting global.retroachievements.username)"
  set_ini "${CONF}" Achievements ChallengeMode "$(to_bool "$(get_setting global.retroachievements.hardcore)")"
  set_ini "${CONF}" Achievements EncoreMode "$(to_bool "$(get_setting global.retroachievements.encore)")"
  set_ini "${CONF}" Achievements LeaderboardNotifications "$(to_bool "$(get_setting global.retroachievements.leaderboards)")"
  set_ini "${CONF}" Achievements UnofficialTestMode "$(to_bool "$(get_setting global.retroachievements.unofficial)")"
  set_ini "${CONF}" Achievements LoginTimestamp "$(date +%s%N | cut -b1-13)"
  set_ini "${SECRETS}" Achievements Token "${TOKEN}"
else
  set_ini "${CONF}" Achievements Enabled false
fi

CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
case "${CORES}" in
  little) EMUPERF="${SLOW_CORES}" ;;
  big) EMUPERF="${FAST_CORES}" ;;
  *) unset EMUPERF ;;
esac

export QT_QPA_PLATFORM=wayland

if [ -n "${1}" ]; then
  ${EMUPERF} /usr/share/pcsx2-sa/pcsx2-qt -batch -nogui -fullscreen -- "${1}"
else
  sway_fullscreen "pcsx2-qt" &
  /usr/share/pcsx2-sa/pcsx2-qt -bigpicture -fullscreen
fi
