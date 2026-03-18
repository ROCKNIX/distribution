#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 gopher64"

# Conf files vars
SOURCE_DIR="/usr/config/gopher64"
CONF_DIR="/storage/.config/gopher64"
GOPHER64_JSON="config.json"

#Check if gopher64 exists in /storage/.config
if [ ! -d "${CONF_DIR}" ]; then
  cp -r "${SOURCE_DIR}" "/storage/.config/"
fi

#Check if config.json exists in .config/gopher64
if [ ! -f "${CONF_DIR}/${GOPHER64_JSON}" ]; then
  cp -r "${SOURCE_DIR}/${GOPHER64_JSON}" "${CONF_DIR}"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
UPSCALE=$(get_setting upscale "${PLATFORM}" "${GAME}")
INTEGERSCALING=$(get_setting integer_scaling "${PLATFORM}" "${GAME}")
WIDESCREEN=$(get_setting wide_screen "${PLATFORM}" "${GAME}")
CRTFILTER=$(get_setting crt_filter "${PLATFORM}" "${GAME}")
OVERCLOCKN64=$(get_setting overclock_n64 "${PLATFORM}" "${GAME}")

# Upscaling
if [[ "$UPSCALE" =~ ^[1-4]$ ]]; then
  sed -Ei "s/^([[:space:]]*)\"upscale\":.*/\1\"upscale\": $UPSCALE,/" "${CONF_DIR}/${GOPHER64_JSON}"
else
  sed -Ei "s/^([[:space:]]*)\"upscale\":.*/\1\"upscale\": 1,/" "${CONF_DIR}/${GOPHER64_JSON}"
fi

# Integer Scaling
if [[ "$INTEGERSCALING" =~ ^(true|false)$ ]]; then
  sed -Ei "s/^([[:space:]]*)\"integer_scaling\":.*/\1\"integer_scaling\": $INTEGERSCALING,/" "${CONF_DIR}/${GOPHER64_JSON}"
else
  sed -Ei "s/^([[:space:]]*)\"integer_scaling\":.*/\1\"integer_scaling\": false,/" "${CONF_DIR}/${GOPHER64_JSON}"
fi

# Widescreen
if [[ "$WIDESCREEN" =~ ^(true|false)$ ]]; then
  sed -Ei "s/^([[:space:]]*)\"widescreen\":.*/\1\"widescreen\": $WIDESCREEN,/" "${CONF_DIR}/${GOPHER64_JSON}"
else
  sed -Ei "s/^([[:space:]]*)\"widescreen\":.*/\1\"widescreen\": false,/" "${CONF_DIR}/${GOPHER64_JSON}"
fi

# CRT Filter
if [[ "$CRTFILTER" =~ ^(true|false)$ ]]; then
  sed -Ei "s/^([[:space:]]*)\"crt\":.*/\1\"crt\": $CRTFILTER/" "${CONF_DIR}/${GOPHER64_JSON}"
else
  sed -Ei "s/^([[:space:]]*)\"crt\":.*/\1\"crt\": false/" "${CONF_DIR}/${GOPHER64_JSON}"
fi

# Overclock N64
if [[ "$OVERCLOCKN64" =~ ^(true|false)$ ]]; then
  sed -Ei "s/^([[:space:]]*)\"overclock\":.*/\1\"overclock\": $OVERCLOCKN64,/" "${CONF_DIR}/${GOPHER64_JSON}"
else
  sed -Ei "s/^([[:space:]]*)\"overclock\":.*/\1\"overclock\": false,/" "${CONF_DIR}/${GOPHER64_JSON}"
fi

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

#Set correct input device
GAMEPAD=$(grep -l "Microsoft Xbox Series S|X Controller" /sys/class/input/event*/device/name | sed -E 's#.*/(event[0-9]+).*#/dev/input/\1#')
if [[ -n "$GAMEPAD" ]]; then
  sed -Ei "/\"controller_assignment\": \[/ { n; s#\"[^\"]*\"#\"$GAMEPAD\"#; }" "${CONF_DIR}/${GOPHER64_JSON}"
else
  GAMEPAD="ERROR: No matching gamepad found."
fi

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CONF DIR: ${CONF_DIR}/${GOPHER64_JSON}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "UPSCALE set to: ${UPSCALE}"
  echo "INTEGER SCALING set to: ${INTEGERSCALING}"
  echo "WIDESCREEN set to: ${WIDESCREEN}"
  echo "CRT FILTER set to: ${CRTFILTER}"
  echo "OVERCLOCK N64 set to: ${OVERCLOCKN64}"
  echo "GAMEPAD set to: ${GAMEPAD}"
  echo "Launching /usr/bin/gopher64 ${1}"

# Start Gopher64
${EMUPERF} /usr/bin/gopher64 -f "${1}"
