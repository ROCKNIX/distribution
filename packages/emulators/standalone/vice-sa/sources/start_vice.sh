#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 @EMU@"

CONFIG_PATH="/storage/.config/vice"
SOURCE_PATH="/usr/config/vice"

EMU="@EMU@"

### Get the game we want to start.
GAME=${1//[\\]/}

if [ ! -d "/storage/.config/vice" ]
then
  mkdir -p /storage/.config/vice
fi

case ${EMU} in
  x128)
    EMU="C128"
  ;;
  x64sc)
    EMU="C64SC"
  ;;
  xplus4)
    EMU="PLUS4"
  ;;
  xvic)
    EMU="VIC20"
  ;;
esac

if [ ! -e "${CONFIG_PATH}/sdl-hotkeys-${EMU}.vhk" ]
then
  cat <<EOF >${CONFIG_PATH}/sdl-hotkeys-${EMU}.vhk
!CLEAR
EOF
fi

if [ ! -e "${CONFIG_PATH}/sdl-joymap-${EMU}.vjm" ]
then
  cat <<EOF >${CONFIG_PATH}/sdl-joymap-${EMU}.vjm
!CLEAR

0 0 0 0
0 0 1 0
0 0 2 0
0 0 3 0
0 0 4 0
0 0 5 0
0 0 6 0
0 0 7 0

0 1 0 1 0 16
0 1 1 1 0 32
0 1 2 1 0 64
0 1 3 0
0 1 4 0
0 1 ${DEVICE_BTN_SELECT} 5 Virtual keyboard
0 1 ${DEVICE_BTN_START} 4
EOF

  if [[ ! "${DEVICE_BTN_DPAD_UP}" =~ [a-z] ]]
  then
    cat <<EOF >>${CONFIG_PATH}/sdl-joymap-${EMU}.vjm
0 1 ${DEVICE_BTN_DPAD_UP} 1 0 1
0 1 ${DEVICE_BTN_DPAD_DOWN} 1 0 2
0 1 ${DEVICE_BTN_DPAD_LEFT} 1 0 4
0 1 ${DEVICE_BTN_DPAD_RIGHT} 1 0 8
EOF
  else
    cat <<EOF >>${CONFIG_PATH}/sdl-joymap-${EMU}.vjm
0 2 0 1 0 1
0 2 1 1 0 2
0 2 2 1 0 4
0 2 3 1 0 8
EOF
  fi
fi

@EMU@ -joymenucontrol "${GAME}"
