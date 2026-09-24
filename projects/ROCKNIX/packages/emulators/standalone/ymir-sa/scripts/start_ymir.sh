#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 ymir"

SOURCE_DIR="/usr/config/ymir"
CONF_DIR="/storage/.config/ymir"
CONF_FILE="${CONF_DIR}/Ymir.toml"
DATA_DIR="/storage/roms/saturn/ymir"

mkdir -p "${CONF_DIR}" "${DATA_DIR}/backup/exported" "/storage/roms/bios/ymir/cdb" \
         "/storage/roms/savestates/saturn/ymir" "/storage/roms/screenshots"
[ -f "${CONF_FILE}" ] || cp "${SOURCE_DIR}/Ymir.toml" "${CONF_FILE}"
[ -f "${CONF_DIR}/ymir.gptk" ] || cp "${SOURCE_DIR}/ymir.gptk" "${CONF_DIR}/"

# Set a key inside one [Section] of Ymir.toml
set_toml() {
  sed -i "/^\[${1//./\\.}\]$/,/^\[/ s|^${2} = .*|${2} = ${3}|" "${CONF_FILE}"
}

# Emulation Station features
GAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM=$(echo "${2}" | sed "s#^/.*/##")

bool_setting() {
  [ "$(get_setting "${1}" "${PLATFORM}" "${GAME}")" = "true" ] && echo true || echo false
}

pad_setting() {
  case "$(get_setting "${1}" "${PLATFORM}" "${GAME}")" in
    AnalogPad|ArcadeRacer|MissionStick|None) echo "\"$(get_setting "${1}" "${PLATFORM}" "${GAME}")\"" ;;
    *) echo "\"ControlPad\"" ;;
  esac
}

case "$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")" in
  16x9) ASPECT="1.7777777777777777" ;;
  *) ASPECT="1.3333333333333333" ;;
esac

set_toml Video FullScreen true
set_toml Video ForceAspectRatio true
set_toml Video ForcedAspect "${ASPECT}"
set_toml Video ForceIntegerScaling "$(bool_setting integer_scaling)"
set_toml Video.Enhancements Deinterlace "$(bool_setting deinterlace)"
set_toml Video.Enhancements TransparentMeshes "$(bool_setting transparent_meshes)"
set_toml System InternalBackupRAMPerGame "$(bool_setting per_game_backup_ram)"
set_toml Input.Port1 PeripheralType "$(pad_setting controller_type_p1)"
set_toml Input.Port2 PeripheralType "$(pad_setting controller_type_p2)"

# Select-based hotkeys; Select+Start sends Alt+F4 (Ymir's exit) before killing.
export PCKILLMODE="Y"
/usr/bin/gptokeyb -k ymir -c "${CONF_DIR}/ymir.gptk" &

cd "${CONF_DIR}"
/usr/bin/ymir -p "${CONF_DIR}" -f "${1}"

kill -9 $(pidof gptokeyb) 2>/dev/null
