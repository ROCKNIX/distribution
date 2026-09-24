#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 shadps4"

SOURCE_DIR="/usr/config/shadps4"
CONF_DIR="/storage/.config/shadPS4"
CONF_FILE="${CONF_DIR}/config.json"
ROMS_DIR="/storage/roms/ps4"
BIOS_DIR="/storage/roms/bios/shadps4"

mkdir -p "${CONF_DIR}/input_config" "${ROMS_DIR}/DLC" "${ROMS_DIR}/shadps4/home" \
         "${BIOS_DIR}/sys_modules" "${BIOS_DIR}/fonts/font" "${BIOS_DIR}/fonts/font2"
[ -f "${CONF_FILE}" ] || cp "${SOURCE_DIR}/config.json" "${CONF_FILE}"
[ -f "${CONF_DIR}/input_config/global.ini" ] || cp "${SOURCE_DIR}/input_config/global.ini" "${CONF_DIR}/input_config/"

# Emulation Station features
GAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM=$(echo "${2}" | sed "s#^/.*/##")

bool_setting() {
  [ "$(get_setting "${1}" "${PLATFORM}" "${GAME}")" = "true" ] && echo true || echo false
}

case "$(get_setting present_mode "${PLATFORM}" "${GAME}")" in
  fifo) PRESENT="Fifo" ;;
  immediate) PRESENT="Immediate" ;;
  *) PRESENT="Mailbox" ;;
esac

case "$(get_setting readbacks_mode "${PLATFORM}" "${GAME}")" in
  1|2) READBACKS="$(get_setting readbacks_mode "${PLATFORM}" "${GAME}")" ;;
  *) READBACKS=0 ;;
esac

jq --arg roms "${ROMS_DIR}" \
   --arg dlc "${ROMS_DIR}/DLC" \
   --arg home "${ROMS_DIR}/shadps4/home" \
   --arg sysmodules "${BIOS_DIR}/sys_modules" \
   --arg fonts "${BIOS_DIR}/fonts" \
   --arg present "${PRESENT}" \
   --argjson readbacks "${READBACKS}" \
   --argjson fsr "$(bool_setting fsr_upscaling)" \
   --argjson fps "$(bool_setting show_fps)" \
   --argjson neo "$(bool_setting ps4_pro_mode)" \
   --argjson copybuffers "$(bool_setting copy_gpu_buffers)" \
   --argjson log "$(bool_setting logging)" '
  .General.install_dirs = [{"path": $roms, "enabled": true}]
  | .General.addon_install_dir = $dlc
  | .General.home_dir = $home
  | .General.sys_modules_dir = $sysmodules
  | .General.font_dir = $fonts
  | .General.show_fps_counter = $fps
  | .General.neo_mode = $neo
  | .GPU.full_screen = true
  | .GPU.full_screen_mode = "Fullscreen (Borderless)"
  | .GPU.present_mode = $present
  | .GPU.fsr_enabled = $fsr
  | .GPU.copy_gpu_buffers = $copybuffers
  | .GPU.readbacks_mode = $readbacks
  | .Input.default_controller_id = ""
  | .Log.enable = $log' "${CONF_FILE}" >"${CONF_FILE}.tmp" && mv "${CONF_FILE}.tmp" "${CONF_FILE}"

# shadPS4 keeps its user folder in ${XDG_DATA_HOME}/shadPS4
export XDG_DATA_HOME="/storage/.config"
cd "${CONF_DIR}"

if [ -z "${1}" ]; then
  /usr/bin/shadps4 --big-picture
  exit
fi

# Games are dumped folders (*.ps4), a file inside one, or a ZArchive (*.zar)
if [ -d "${1}" ] || [[ "${1}" == *.zar ]]; then
  TARGET="${1}"
else
  TARGET="$(dirname "${1}")"
fi

/usr/bin/shadps4 --fullscreen true --game "${TARGET}"
