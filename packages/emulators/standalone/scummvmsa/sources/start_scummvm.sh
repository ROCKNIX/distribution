#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

CONFIG_DIR="/storage/.config/scummvm"
ROMSPATH="/storage/roms"
BIOSPATH="${ROMSPATH}/bios"
RATMPCONF="/storage/.config/retroarch/retroarch.cfg"

shopt -s extglob
if [[ "$1" =~ ?(add|create|libretro) ]]
then
  GAME="$2"
else
  GAME="$1"
fi

if [ ! -d "${CONFIG_DIR}/games" ]
then
  mkdir -p "${CONFIG_DIR}/games"
fi

create_svm(){
  /usr/bin/scummvm --list-targets | tail -n +3 | cut -d " " -f 1 | \
  while read line
  do
    id=($line);
    filename=$(grep -A7 "\[$id\]" ${CONFIG_DIR}/scummvm.ini | \
      awk 'BEGIN {FS="="}; /description/ {printf $2}' | \
      sed -e 's# (.*)# ('${id}')#g' -e "s#'##g" -e "s#: # - #g" \
    )

    SVMPATH="$(grep -A7 "\[$id\]" ${CONFIG_DIR}/scummvm.ini | awk 'BEGIN {FS="="}; /path/ {print $2}')"
    echo '--path="'${SVMPATH}'" '${id} >"${CONFIG_DIR}/games/${filename}.scummvm"
  done
}

if [ ! -d "${CONFIG_DIR}" ]; then
 mkdir -p ${CONFIG_DIR}
 cp -rf /usr/config/scummvm/* ${CONFIG_DIR}/
fi

case $1 in
  "libretro")
    GAME=$(cat "${GAME}" | awk 'BEGIN {FS="\""}; {print $2}')
    cd "${GAME}"
    /usr/bin/retroarch -L /tmp/cores/scummvm_libretro.so --config ${RATMPCONF} .
  ;;

  "add")
    /usr/bin/scummvm --add --path="${ROMSPATH}/scummvm" --recursive
    mkdir -p ${BIOSPATH}
    cp ${CONFIG_DIR}/scummvm.ini ${BIOSPATH}/scummvm.ini
  ;;

  "create")
    create_svm
  ;;

  *)
    GAME=$(cat "${GAME}")
    systemctl start fluidsynth
    eval /usr/bin/scummvm --fullscreen --joystick=0 --themepath=/usr/config/scummvm/themes "${GAME}"
    systemctl stop fluidsynth
  ;;
esac
