#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 ares"

CONF_DIR="/storage/.config/ares"
ARES_INI="settings.bml"

# Check if ares exists in .config
if [ ! -d "${CONF_DIR}" ]; then
  cp -r "/usr/config/ares" "/storage/.config/"
fi

# Check if settings.bml exists in .config/ares/
if [ ! -f "${CONF_DIR}/${ARES_INI}" ]; then
  cp -r "/usr/config/ares/${ARES_INI}" "${CONF_DIR}/"
fi

# AMD64: bind the virtual pad to player 1 by GUID and position from its ES mapping
if [ "${HW_DEVICE}" = "AMD64" ] && mkcontroller; then
  . /storage/.config/profile.d/098-controller
  GUID="$(control-gen | awk 'BEGIN {FS="\""} /^DEVICE/ {print $2; exit}')"
  # ares groups: 0 axes, 1 hats (X, Y per hat), 3 buttons
  ares_in() {
    case "$1" in
      h*) local n=${1:1:1}
          case "${1:2}" in up) echo "1/$(( n * 2 + 1 ))/Lo" ;; down) echo "1/$(( n * 2 + 1 ))/Hi" ;;
                           left) echo "1/$(( n * 2 ))/Lo" ;; *) echo "1/$(( n * 2 ))/Hi" ;; esac ;;
      *-) echo "0/${1%?}/Lo" ;;
      *+) echo "0/${1%?}/Hi" ;;
      *) echo "3/$1" ;;
    esac
  }
  for kv in "Pad.Up=${DEVICE_BTN_DPAD_UP}" "Pad.Down=${DEVICE_BTN_DPAD_DOWN}" "Pad.Left=${DEVICE_BTN_DPAD_LEFT}" \
            "Pad.Right=${DEVICE_BTN_DPAD_RIGHT}" "Select=${DEVICE_BTN_SELECT}" "Start=${DEVICE_BTN_START}" \
            "A..South=${DEVICE_BTN_SOUTH}" "B..East=${DEVICE_BTN_EAST}" "X..West=${DEVICE_BTN_WEST}" "Y..North=${DEVICE_BTN_NORTH}" \
            "L-Bumper=${DEVICE_BTN_TL}" "R-Bumper=${DEVICE_BTN_TR}" "L-Trigger=${DEVICE_BTN_TL2}" "R-Trigger=${DEVICE_BTN_TR2}" \
            "L-Stick..Click=${DEVICE_BTN_THUMBL}" "R-Stick..Click=${DEVICE_BTN_THUMBR}" \
            "L-Up=${DEVICE_BTN_AL_UP}" "L-Down=${DEVICE_BTN_AL_DOWN}" "L-Left=${DEVICE_BTN_AL_LEFT}" "L-Right=${DEVICE_BTN_AL_RIGHT}" \
            "R-Up=${DEVICE_BTN_AR_UP}" "R-Down=${DEVICE_BTN_AR_DOWN}" "R-Left=${DEVICE_BTN_AR_LEFT}" "R-Right=${DEVICE_BTN_AR_RIGHT}"; do
    [ -n "${kv#*=}" ] && sed -i "/^VirtualPad1$/,/^VirtualMouse1$/ s|^  ${kv%%=*}: .*|  ${kv%%=*}: ${GUID}/0/$(ares_in "${kv#*=}");;|" "${CONF_DIR}/${ARES_INI}"
  done
fi

# Link  .config/ares to .local
rm -rf /storage/.local/share/ares
ln -sf /storage/.config/ares /storage/.local/share/ares

# Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")

# Set the cores to use
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

${EMUPERF} /usr/bin/ares --fullscreen "${1}"
