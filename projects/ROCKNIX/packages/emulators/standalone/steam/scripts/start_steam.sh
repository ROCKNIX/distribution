#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
STEAM_VERSION=$(get_setting steam_version "${PLATFORM}" "${GAME}"); STEAM_VERSION=${STEAM_VERSION:-"arm64"}
# Debugging info:
echo "STEAM_VERSION set to: ${STEAM_VERSION}"
if [ "${STEAM_VERSION}" = "arm64" ]; then
  /usr/bin/start_steam_arm64.sh "$@"
else
  /usr/bin/start_steam_x86.sh "$@"
fi
