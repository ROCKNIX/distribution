#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 AppRun.wrapped"

# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/duckstation"
IMMUTABLE_CONF_FILE="${IMMUTABLE_CONF_DIR}/settings.ini"
APPIMAGE_CONF_DIR="/storage/.local/share/duckstation"
CONF_DIR="/storage/.config/duckstation"
CONF_FILE="${CONF_DIR}/settings.ini"

#Init config dir if required
[ ! -d "${CONF_DIR}" ] && cp -r "${IMMUTABLE_CONF_DIR}" /storage/.config

#Link config dir to where appimage can find it
mkdir -p /storage/.local/share
rm -rf "${APPIMAGE_CONF_DIR}"
ln -sfv "${CONF_DIR}" "${APPIMAGE_CONF_DIR}"

#Init config file if required
[ ! -f "${CONF_FILE}" ] && cp ${IMMUTABLE_CONF_FILE} ${CONF_FILE}

#Link gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt "${CONF_DIR}/gamecontrollerdb.txt"

/usr/bin/duckstation-sa -fullscreen -bigpicture
