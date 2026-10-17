#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present redwolftech
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "mpv"
systemctl start mpv

FBWIDTH="$(fbwidth)"
FBHEIGHT="$(fbheight)"

if [[ ${FBWIDTH} -ge ${FBHEIGHT} ]]; then
  RES="${FBWIDTH}x${FBHEIGHT}"
else
  RES="${FBHEIGHT}x${FBWIDTH}"
fi

/usr/bin/mpv --fullscreen --geometry=${RES} --input-gamepad=yes --input-ipc-server=/tmp/mpvsocket "${1}"
systemctl stop mpv
exit 0
