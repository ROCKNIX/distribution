#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# Source predefined functions and variables
. /etc/profile

GAME_DIR="/storage/roms/pico-8/"

case ${HW_ARCH} in
  aarch64)
    STATIC_BIN="pico8_64"
  ;;
  *)
    STATIC_BIN="pico8_dyn"
  ;;
esac

# check if the file being launched contains "Splore" and if so launch Pico-8 Splore otherwise run the game directly
shopt -s nocasematch
if [[ "${1}" == *splore* ]]; then
  OPTIONS="-splore"
else
  OPTIONS="-run"
  CART="${1}"
fi
shopt -u nocasematch

INTEGER_SCALE=$(get_setting pico-8.integerscale)
if [ "${INTEGER_SCALE}" = "1" ]
then
  OPTIONS="${OPTIONS} -pixel_perfect 1"
fi

if [ -d "${GAME_DIR}/${HW_ARCH}" ]
then
  LAUNCH_DIR="${GAME_DIR}/${HW_ARCH}"
else
  LAUNCH_DIR="${GAME_DIR}"
fi

# store sdl_controllers in root directory so its shared across devices - will look to revisit this with controller refactor work
cp -f /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt ${GAME_DIR}/sdl_controllers.txt

# mark the binary executable to cover cases where the user adding the binaries doesn't know or forgets.
chmod 0755 ${LAUNCH_DIR}/${STATIC_BIN}
set_kill set "-9 ${STATIC_BIN} start_pico8.sh"
${LAUNCH_DIR}/${STATIC_BIN} -home -root_path ${GAME_DIR} -joystick 0 ${OPTIONS} "${CART}"