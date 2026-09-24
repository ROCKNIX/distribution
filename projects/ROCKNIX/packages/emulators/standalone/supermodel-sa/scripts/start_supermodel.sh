#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

# Source predefined functions and variables
. /etc/profile
set_kill set "-9 supermodel"

CONFIG_DIR="/storage/.config/supermodel"
SOURCE_DIR="/usr/config/supermodel"

#Check if supermodel exists in .config
if [ ! -d "${CONFIG_DIR}" ]; then
    mkdir -p "${CONFIG_DIR}"
        cp -r "${SOURCE_DIR}" "/storage/.config/"
fi

if [ ! -d "${CONFIG_DIR}/NVRAM" ]; then
    mkdir -p "${CONFIG_DIR}/NVRAM"
fi

if [ ! -d "${CONFIG_DIR}/Saves" ]; then
    mkdir -p "${CONFIG_DIR}/Saves"
fi

if [ ! -d "${CONFIG_DIR}/LocalConfig" ]; then
    mkdir -p "${CONFIG_DIR}/LocalConfig"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
RESOLUTION=$(get_setting resolution "${PLATFORM}" "${GAME}")
ENGINE=$(get_setting rendering_engine "${PLATFORM}" "${GAME}")

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

OPTIONS=" -fullscreen"

#VSYNC
if [ "$VSYNC" = "true" ]
then
  OPTIONS+=" -vsync"
elif [ "$VSYNC" = "false" ]
then
  OPTIONS+=" -no-vsync"
fi

#ENGINE
if [ "$ENGINE" = "1" ]
then
  OPTIONS+=" -new3d"
elif [ "$ENGINE" = "0" ]
then
  OPTIONS+=" -legacy3d"
fi

#RESOLUTION
if [ "$RESOLUTION" = "0" ]
then
  OPTIONS+=" -res=1920,1080"
elif [ "$RESOLUTION" = "1" ]
then
  OPTIONS+=" -res=496,384"
elif [ "$RESOLUTION" = "2" ]
then
  OPTIONS+=" -res=992,768"
elif [ "${HW_DEVICE}" = "AMD64" ]
then
  OPTIONS+=" -res=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | "\(.rect.width),\(.rect.height)"')"
fi

# Preset NVRAM (single cabinet etc.); never overwrite existing ones
mkdir -p /storage/.config/supermodel/NVRAM
cp -n /usr/config/supermodel/NVRAM/*.nv /storage/.config/supermodel/NVRAM/ 2>/dev/null

# AMD64: player 1's buttons by position from its ES mapping. The shipped layout numbers
# buttons 1 south, 2 east, 3 west, 4 north, 5/6 L1/R1, 7 select, 9 start, 12-15 D-pad.
if [ "${HW_DEVICE}" = "AMD64" ] && mkcontroller; then
  . /storage/.config/profile.d/098-controller
  b() { [[ "$1" =~ ^[0-9]+$ ]] && echo "JOY1_BUTTON$(( $1 + 1 ))"; }
  HK="$(b ${DEVICE_BTN_SELECT})"
  awk -v m="1=$(b ${DEVICE_BTN_SOUTH}) 2=$(b ${DEVICE_BTN_EAST}) 3=$(b ${DEVICE_BTN_WEST}) 4=$(b ${DEVICE_BTN_NORTH}) 5=$(b ${DEVICE_BTN_TL}) 6=$(b ${DEVICE_BTN_TR}) 7=${HK} 9=$(b ${DEVICE_BTN_START}) 12=$(b ${DEVICE_BTN_DPAD_UP}) 13=$(b ${DEVICE_BTN_DPAD_DOWN}) 14=$(b ${DEVICE_BTN_DPAD_LEFT}) 15=$(b ${DEVICE_BTN_DPAD_RIGHT})" \
    -v ui="InputUIExit=${HK}+$(b ${DEVICE_BTN_START}) InputUIPause=${HK}+$(b ${DEVICE_BTN_NORTH}) InputUISaveState=${HK}+$(b ${DEVICE_BTN_TR}) InputUILoadState=${HK}+$(b ${DEVICE_BTN_TL}) InputServiceA=${HK}+$(b ${DEVICE_BTN_THUMBL}) InputTestA=${HK}+$(b ${DEVICE_BTN_THUMBR}) InputUISelectCrosshairs=" '
    BEGIN {
      n = split(m, a, " "); for (i = 1; i <= n; i++) { split(a[i], kv, "="); map[kv[1]] = kv[2] }
      n = split(ui, a, " "); for (i = 1; i <= n; i++) { split(a[i], kv, "="); fix[kv[1]] = kv[2] }
    }
    FNR == NR {
      if (match($0, /^Input[A-Za-z0-9]+/) && $0 ~ /JOY1_/) {
        key = substr($0, 1, RLENGTH); line = $0
        if (key in fix) {
          if (match(line, /"[^"]*"/)) {
            k = split(substr(line, RSTART + 1, RLENGTH - 2), it, ","); keep = ""
            for (j = 1; j <= k; j++) if (it[j] !~ /JOY1_/) keep = keep (keep == "" ? "" : ",") it[j]
            if (fix[key] != "") keep = keep (keep == "" ? "" : ",") fix[key]
            line = substr(line, 1, RSTART) keep substr(line, RSTART + RLENGTH - 1)
          }
        }
        else {
          out = ""
          while (match(line, /JOY1_BUTTON[0-9]+/)) {
            num = substr(line, RSTART + 11, RLENGTH - 11)
            out = out substr(line, 1, RSTART - 1) ((num in map && map[num] != "") ? map[num] : "JOY1_BUTTON" num)
            line = substr(line, RSTART + RLENGTH)
          }
          line = out line
        }
        new[key] = line
      }
      next
    }
    { if (match($0, /^Input[A-Za-z0-9]+/) && (substr($0, 1, RLENGTH) in new)) print new[substr($0, 1, RLENGTH)]; else print }
  ' /usr/config/supermodel/Config/Supermodel.ini /storage/.config/supermodel/Config/Supermodel.ini >/tmp/Supermodel.ini &&
    cp /tmp/Supermodel.ini /storage/.config/supermodel/Config/Supermodel.ini
fi

sway_fullscreen supermodel &

cd ${CONFIG_DIR}
echo "Command: supermodel ${1} ${OPTIONS}" >/var/log/exec.log 2>&1
${EMUPERF} supermodel "${1}" "${OPTIONS}" >>/var/log/exec.log 2>&1 ||:
