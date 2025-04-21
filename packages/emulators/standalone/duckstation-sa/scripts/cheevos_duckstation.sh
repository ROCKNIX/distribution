#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

DUCK_CFG="/storage/.config/duckstation/settings.ini"
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
    sed -i '/\[Cheevos\]/,/^\s*$/s/Enabled =.*/Enabled = false/' ${DUCK_CFG}
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
zcheevos=$(grep -Fx "[Cheevos]" ${DUCK_CFG})
datets=$(date +%s%N | cut -b1-13)

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [Cheevos]\nEnabled = true\nUsername = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}\nChallengeMode = ${hardcore}" ${DUCK_CFG}
else
    sed -i '/\[Cheevos\]/,/^\s*$/s/Enabled =.*/Enabled = true/' ${DUCK_CFG}
    if ! grep -q "^Username = " ${DUCK_CFG}; then
        sed -i "/^\[Cheevos\]/a Username = ${username}" ${DUCK_CFG}
    else
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${DUCK_CFG}
    fi

    if ! grep -q "^Token = " ${DUCK_CFG}; then
        sed -i "/^\[Cheevos\]/a Token = ${token}" ${DUCK_CFG}
    else
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${DUCK_CFG}
    fi

    if ! grep -q "^ChallengeMode = " ${DUCK_CFG}; then
        sed -i "/^\[Cheevos\]/a ChallengeMode = ${hardcore}" ${DUCK_CFG}
    else
        sed -i "/^\[Cheevos\]/,/^\[/{s/^ChallengeMode = .*/ChallengeMode = ${hardcore}/;}" ${DUCK_CFG}
    fi

   sed -i "/^\[Cheevos\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" ${DUCK_CFG}
fi
