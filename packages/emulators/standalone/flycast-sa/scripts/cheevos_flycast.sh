#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

FLYCAST_CFG="/storage/.config/flycast/emu.cfg"

username=$(get_setting "global.retroachievements.username")
password=$(get_setting "global.retroachievements.password")
token=$(get_setting "global.retroachievements.token")

# Test the token if empty exit 1.
if [ -z "${token}" ]; then
    echo "Token is empty you must log in retroachievements first in Emulation Station" > /var/log/cheevos.log
    exit 1
fi

# Variables for checking if [Cheevos] or enabled true or false are present.
zcheevos=$(grep -Fx "[achievements]" ${FLYCAST_CFG})

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [achievements]\nEnabled = yes\nUserName = ${username}\nToken = ${token}" ${FLYCAST_CFG}
else
    sed -i '/\[achievements\]/,/^\s*$/s/Enabled =.*/Enabled = yes/' ${FLYCAST_CFG}
    if ! grep -q "^UserName = " ${FLYCAST_CFG}; then
        sed -i "/^\[achievements\]/a UserName = ${username}" ${FLYCAST_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^UserName = .*/UserName = ${username}/;}" ${FLYCAST_CFG}
    fi

    if ! grep -q "^Token = " ${FLYCAST_CFG}; then
        sed -i "/^\[achievements\]/a Token = ${token}" ${FLYCAST_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${FLYCAST_CFG}
    fi
fi
