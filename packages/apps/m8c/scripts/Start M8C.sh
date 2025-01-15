#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC

source /etc/profile

set_kill set "-9 m8c"

M8C_DIR="/storage/.local/share/m8c"
M8C_CONF_DIR="/usr/config/m8c"

if [ ! -d ${M8C_DIR} ]; then
  mkdir -p ${M8C_DIR}
fi

if [ ! -f "${M8C_DIR}/config.ini" ]; then
    if [ -f "${M8C_CONF_DIR}/${QUIRK_DEVICE}.ini" ]; then
        cp "${M8C_CONF_DIR}/${QUIRK_DEVICE}.ini" "${M8C_DIR}/config.ini"
    else
        if [ -f "${M8C_CONF_DIR}/config.ini" ]; then
            cp "${M8C_CONF_DIR}/config.ini" "${M8C_DIR}/config.ini"
        fi
    fi
fi

/usr/bin/m8c
