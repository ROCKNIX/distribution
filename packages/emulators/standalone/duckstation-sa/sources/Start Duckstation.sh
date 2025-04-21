#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 duckstation-sa"

# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/duckstation"
CONF_DIR="/storage/.local/share/duckstation"
CONF_FILE="${CONF_DIR}/settings.ini"

#Copy config folder to .local/share/duckstation
if [ ! -d "${CONF_DIR}" ]; then
    mkdir -p "${CONF_DIR}"
    cp -r "${IMMUTABLE_CONF_DIR}" "/storage/.local/share/"
fi

if [ ! -f "${CONF_FILE}" ]; then
   cp ${IMMUTABLE_CONF_DIR}/settings.ini ${CONF_FILE}
fi

#Link gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt "${CONF_DIR}/gamecontrollerdb.txt"

#sway_fullscreen "duckstation-sa" "pgrep"  &

/usr/bin/duckstation-sa -fullscreen
