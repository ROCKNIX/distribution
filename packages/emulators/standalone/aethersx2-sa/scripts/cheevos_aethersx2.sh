#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

AETHERSX2_CFG="/storage/.config/aethersx2/inis/PCSX2.ini"

# Extract username and password from emuelec.conf
username=$(get_setting "global.retroachievements.username")
password=$(get_setting "global.retroachievements.password")
token=$(get_setting "global.retroachievements.token")

# Test the token if empty exit 1.
if [ -z "${token}" ]; then
    echo "Token is empty you must log in retroachievements first in Emulation Station" > /var/log/cheevos.log
    exit 1
fi

# Variables for checking if [Cheevos] or enabled true or false are present.
zcheevos=$(grep -Fx "[achievements]" ${AETHERSX2_CFG})

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [Achievements]\nEnabled = true\nUsername = ${username}\nToken = ${token}" ${AETHERSX2_CFG}
else
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = true/' ${AETHERSX2_CFG}
    if ! grep -q "^UserName = " ${AETHERSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Username = ${username}" ${AETHERSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${AETHERSX2_CFG}
    fi

    if ! grep -q "^Token = " ${AETHERSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Token = ${token}" ${AETHERSX2_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${AETHERSX2_CFG}
    fi
fi
