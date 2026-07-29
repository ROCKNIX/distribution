#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

ARMSX2_CFG="/storage/.config/ARMSX2/inis/PCSX2.ini"
ARMSX2_TOKEN="/storage/.config/ARMSX2/inis/secrets.ini"
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
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = false/' ${ARMSX2_CFG}
    exit 1
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

# Update emulator config with RetroAchievements settings
zcheevos=$(grep -Fx "[Achievements]" ${ARMSX2_CFG})
datets=$(date +%s%N | cut -b1-13)

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [Achievements]\nEnabled = true\nUsername = ${username}\nChallengeMode = ${hardcore}\nLoginTimestamp = ${datets}" ${ARMSX2_CFG}
    sed -i "\$a [Achievements]\nToken = ${token}" ${ARMSX2_TOKEN}
else
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = true/' ${ARMSX2_CFG}

    if ! grep -q "^Username = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Username = ${username}" ${ARMSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${ARMSX2_CFG}
    fi

    if ! grep -q "^Token = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Token = ${token}" ${ARMSX2_TOKEN}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${ARMSX2_TOKEN}
    fi

    if ! grep -q "^ChallengeMode = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a ChallengeMode = ${hardcore}" ${ARMSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^ChallengeMode = .*/ChallengeMode = ${hardcore}/;}" ${ARMSX2_CFG}
    fi

    if ! grep -q "^EncoreMode = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a EncoreMode = ${encore}" ${ARMSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^EncoreMode = .*/EncoreMode = ${encore}/;}" ${ARMSX2_CFG}
    fi

    if ! grep -q "^LeaderboardNotifications = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a LeaderboardNotifications = ${leaderboards}" ${ARMSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^LeaderboardNotifications = .*/LeaderboardNotifications = ${leaderboards}/;}" ${ARMSX2_CFG}
    fi

    if ! grep -q "^UnofficialTestMode = " ${ARMSX2_CFG}; then
        sed -i "/^\[Achievements\]/a UnofficialTestMode = ${unofficial}" ${ARMSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^UnofficialTestMode = .*/UnofficialTestMode = ${unofficial}/;}" ${ARMSX2_CFG}
    fi

    sed -i "/^\[Achievements\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" ${ARMSX2_CFG}
fi
