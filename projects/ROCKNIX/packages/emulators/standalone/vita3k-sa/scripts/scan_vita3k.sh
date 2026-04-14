#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

GAME_PATH="/storage/roms/psvita/vita3k/ux0/app"
GAME_DATA="/storage/.config/Vita3K/vita-gamelist.txt"
OUTPUT_PATH="/storage/roms/psvita"

cd ${GAME_PATH}
for GAME in PC*
do
  FILENAME=$(grep ${GAME} ${GAME_DATA} | sed 's~'${GAME}'\t~~g')
  if [ ! -e "${OUTPUT_PATH}/${FILENAME}.psvita" ] && \
     [ -n "${FILENAME}" ]
  then
    echo ${GAME} > ${OUTPUT_PATH}/"${FILENAME}.psvita"
  fi
done
