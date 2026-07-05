k#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

YAPS2_CFG="/storage/.config/YAPS2/inis/YAPS2.ini"
YAPS2_TOKEN="/storage/.config/YAPS2/inis/security.ini"
LOG_FILE="/var/log/cheevos.log"

# Extract username, password, token, if enabled, and hardcore mode from system.cfg
username=$(get_setting "global.retroachievements.username")
password=$(get_setting "global.retroachievements.password")
token=$(get_setting "global.retroachievements.token")
enabled=$(get_setting "global.retroachievements")
hardcore=$(get_setting "global.retroachievements.hardcore")
encore=$(get_setting "global.retroachievements.encore")
leaderboards=$(get_setting "global.retroachievements.leaderboards")
unofficial=$(get_setting "global.retroachievements.unofficial")

# Convert values from 0/1 to true/false
to_bool() { [ "${1}" = "1" ] && echo "true" || echo "false"; }
hardcore=$(to_bool "${hardcore}")
encore=$(to_bool "${encore}")
leaderboards=$(to_bool "${leaderboards}")
unofficial=$(to_bool "${unofficial}")

# Check if RetroAchievements are enabled in Emulation Station
if [ ! ${enabled} = 1 ]; then
    echo "RetroAchievements are not enabled, please turn them on in Emulation Station." > ${LOG_FILE}
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = false/' ${YAPS2_CFG}
    exit 1
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

# Update emulator config with RetroAchievements settings
zcheevos=$(grep -Fx "[Achievements]" ${YAPS2_CFG})
datets=$(date +%s%N | cut -b1-13)

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [Achievements]\nEnabled = true\nUsername = ${username}\nChallengeMode = ${hardcore}\nLoginTimestamp = ${datets}" ${YAPS2_CFG}
    sed -i "\$a [Achievements]\nToken = ${token}" ${YAPS2_TOKEN}
else
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = true/' ${YAPS2_CFG}

    if ! grep -q "^Username = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a Username = ${username}" ${YAPS2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${YAPS2_CFG}
    fi

    if ! grep -q "^Token = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a Token = ${token}" ${YAPS2_TOKEN}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${YAPS2_TOKEN}
    fi

    if ! grep -q "^ChallengeMode = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a ChallengeMode = ${hardcore}" ${YAPS2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^ChallengeMode = .*/ChallengeMode = ${hardcore}/;}" ${YAPS2_CFG}
    fi

    if ! grep -q "^EncoreMode = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a EncoreMode = ${encore}" ${YAPS2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^EncoreMode = .*/EncoreMode = ${encore}/;}" ${YAPS2_CFG}
    fi

    if ! grep -q "^LeaderboardNotifications = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a LeaderboardNotifications = ${leaderboards}" ${YAPS2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^LeaderboardNotifications = .*/LeaderboardNotifications = ${leaderboards}/;}" ${YAPS2_CFG}
    fi

    if ! grep -q "^UnofficialTestMode = " ${YAPS2_CFG}; then
        sed -i "/^\[Achievements\]/a UnofficialTestMode = ${unofficial}" ${YAPS2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^UnofficialTestMode = .*/UnofficialTestMode = ${unofficial}/;}" ${YAPS2_CFG}
    fi

    sed -i "/^\[Achievements\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" ${YAPS2_CFG}
fi
