#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

FLYCAST_CFG="/storage/.config/flycast/emu.cfg"
LOG_FILE="/var/log/cheevos.log"

# Extract username, password, token, if enabled, and hardcore mode from system.cfg
username=$(get_setting "global.retroachievements.username")
password=$(get_setting "global.retroachievements.password")
token=$(get_setting "global.retroachievements.token")
enabled=$(get_setting "global.retroachievements")
hardcore=$(get_setting "global.retroachievements.hardcore")

# Check if RetroAchievements are enabled in Emulation Station
if [ ! ${enabled} = 1 ]; then
    echo "RetroAchievements are not enabled, please turn them on in Emulation Station." > ${LOG_FILE}
    sed -i '/\[achievements\]/,/^\s*$/s/Enabled =.*/Enabled = no/' ${FLYCAST_CFG}
    exit 1
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

# Set hardcore mode
if [ "${hardcore}" = 1 ]; then
  hardcore="true"
else
  hardcore="false"
fi

# Update emulator config with RetroAchievements settings
zcheevos=$(grep -Fx "[achievements]" ${FLYCAST_CFG})

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [achievements]\nEnabled = yes\nHardcoreMode = ${hardcore}\nUserName = ${username}\nToken = ${token}" ${FLYCAST_CFG}
else
    sed -i '/\[achievements\]/,/^\s*$/s/Enabled =.*/Enabled = yes/' ${FLYCAST_CFG}
    if ! grep -q "^HardcoreMode = " ${FLYCAST_CFG}; then
        sed -i "/^\[achievements\]/a HardcoreMode = ${hardcore}" ${FLYCAST_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^HardcoreMode = .*/HardcoreMode = ${hardcore}/;}" ${FLYCAST_CFG}
    fi

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
