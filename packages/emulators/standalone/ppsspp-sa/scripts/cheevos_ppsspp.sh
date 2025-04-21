#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

PPSSPP_ACHIEVEMENTS="/storage/.config/ppsspp/PSP/SYSTEM/ppsspp_retroachievements.dat"
PPSSPP_INI="/storage/.config/ppsspp/PSP/SYSTEM/ppsspp.ini"
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
    sed -i '/^AchievementsEnable =/c\AchievementsEnable = False' ${PPSSPP_INI}
    exit 1
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

echo "${token}" > ${PPSSPP_ACHIEVEMENTS}

# Set hardcore mode
if [ "${hardcore}" = 1 ]; then
  hardcore="True"
else
  hardcore="False"
fi

# Update emulator config with RetroAchievements settings
zcheevos=$(grep -Fx "[Achievements]" ${PPSSPP_INI})
echo "${token}" > ${PPSSPP_ACHIEVEMENTS}

if [ -z "${zcheevos}" ]
then
    echo -e "[Achievements]\nAchievementsEnable = True\nAchievementsUserName = ${username}\nAchievementsChallengeMode = ${hardcore}" >> ${PPSSPP_INI}
else
    sed -i '/^AchievementsEnable =/c\AchievementsEnable = True' ${PPSSPP_INI}
    if ! grep -q "^AchievementsUserName = " ${PPSSPP_INI}; then
        sed -i "/^\[Achievements\]/a AchievementsUserName = ${username}" ${PPSSPP_INI}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^AchievementsUserName = .*/AchievementsUserName = ${username}/;}" ${PPSSPP_INI}
    fi

    if ! grep -q "^AchievementsChallengeMode = " ${PPSSPP_INI}; then
        sed -i "/^\[Achievements\]/a AchievementsChallengeMode = ${hardcore}" ${PPSSPP_INI}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^AchievementsChallengeMode = .*/AchievementsChallengeMode = ${hardcore}/;}" ${PPSSPP_INI}
    fi
fi
