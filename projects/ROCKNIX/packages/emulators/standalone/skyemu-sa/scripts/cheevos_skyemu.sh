#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

LOG_FILE="/var/log/cheevos.log"

# Extract username, password, token, if enabled, and hardcore mode from system.cfg
username=$(get_setting "global.retroachievements.username")
token=$(get_setting "global.retroachievements.token")
enabled=$(get_setting "global.retroachievements")

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

cat <<EOF >/storage/.config/SkyEmu/ra_token.txt
${username}
${token}
EOF
