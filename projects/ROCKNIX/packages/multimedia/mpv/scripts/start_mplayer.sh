#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present redwolftech
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "mpv"
systemctl start mpv

GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
HWDEC=$(get_setting hardware_decoding "${PLATFORM}" "${GAME}")
RESUME=$(get_setting resume_playback "${PLATFORM}" "${GAME}")

# Window position / size
FBWIDTH="$(fbwidth)"
FBHEIGHT="$(fbheight)"

if [[ ${FBWIDTH} -ge ${FBHEIGHT} ]]; then
  RES="${FBWIDTH}x${FBHEIGHT}"
else
  RES="${FBHEIGHT}x${FBWIDTH}"
fi

# Hardware decode (enabled by default)
[[ "${HWDEC}" == "0" ]] && HWDEC_OPTION="--hwdec=no"

# Auto-resume playback (enabled by default)
[[ "${RESUME}" == "0" ]] && RESUME_OPTION="--resume-playback=no"

/usr/bin/mpv \
  --fullscreen \
  --geometry=${RES} \
  --input-gamepad=yes \
  --input-ipc-server=/tmp/mpvsocket \
  "${HWDEC_OPTION}" \
  "${RESUME_OPTION}" \
  "${1}"

systemctl stop mpv
exit 0
