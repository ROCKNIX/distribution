#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
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
encore=$(get_setting "global.retroachievements.encore")
unofficial=$(get_setting "global.retroachievements.testunofficial")

# Check if RetroAchievements are enabled in Emulation Station
if [ "${enabled}" = 1 ]; then
  enabled="True"
else
  echo "RetroAchievements are not enabled, please turn them on in Emulation Station." > ${LOG_FILE}
  enabled="False"
  exit 1
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

# Set hardcore mode
if [ "${hardcore}" = 1 ]; then
  hardcore="True"
else
  hardcore="False"
fi

# Set encore mode
if [ "${encore}" = 1 ]; then
  encore="True"
else
  encore="False"
fi

# Set unofficial mode
if [ "${unofficial}" = 1 ]; then
  unofficial="True"
else
  unofficial="False"
fi

cat <<EOF >/storage/.config/dolphin-emu/RetroAchievements.ini
[Achievements]
DiscordPresenceEnabled = False
Enabled = ${enabled}
EncoreEnabled = ${encore}
HardcoreEnabled = ${hardcore}
ProgressEnabled = False
SpectatorEnabled = False
UnofficialEnabled = ${unofficial}
Username = ${username}
ApiToken = ${token}
EOF
