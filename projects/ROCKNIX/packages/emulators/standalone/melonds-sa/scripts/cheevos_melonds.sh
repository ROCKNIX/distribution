#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

MELONDS_CFG="/storage/.config/melonDS/melonDS.ini"
LOG_FILE="/var/log/cheevos.log"

: > "${LOG_FILE}"

log() {
  printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "${LOG_FILE}"
}

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
  enabled="1"
else
  log "RetroAchievements are not enabled, please turn them on in Emulation Station."
  enabled="0"
fi

# Check if username is present in system.cfg
if [ -z "${username}" ]; then
    log "RetroAchievements username is empty, please log in with your RetroAchievements credentials in Emulation Station."
    enabled="0"
    username="null"
fi

# Check if password is present in system.cfg
if [ -z "${password}" ]; then
    log "RetroAchievements password is empty, please log in with your RetroAchievements credentials in Emulation Station."
    enabled="0"
    password="null"
fi

# Check if api token is present in system.cfg
if [ -z "${token}" ]; then
    log "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station."
    enabled="0"
    token="null"
fi

# Set hardcore mode
if [ "${hardcore}" = 1 ]; then
  hardcore="1"
else
  hardcore="0"
fi

# Set encore mode
if [ "${encore}" = 1 ]; then
  encore="1"
else
  encore="0"
fi

# Set unofficial mode
if [ "${unofficial}" = 1 ]; then
  unofficial="1"
else
  unofficial="0"
fi

# Clean up any special characters
escape_sed() {
  printf '%s\n' "$1" | sed 's/[\/&]/\\&/g'
}

username_esc=$(escape_sed "${username}")
password_esc=$(escape_sed "${password}")
token_esc=$(escape_sed "${token}")

# Update emulator config with RetroAchievements settings
set_key() {
  key="$1"
  value="$2"

  if grep -q "^[[:space:]]*${key}[[:space:]]*=" "${MELONDS_CFG}"; then
    sed -i "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${value}|g" "${MELONDS_CFG}"
  else
    printf '%s=%s\n' "${key}" "${value}" >> "${MELONDS_CFG}"
  fi
}

set_key RA_Enabled "${enabled}"
set_key RA_Username "${username_esc}"
set_key RA_Password "${password_esc}"
set_key RA_Token "${token_esc}"
set_key RA_HardcoreMode "${hardcore}"
set_key RA_EncoreMode "${encore}"
set_key RA_Unofficial "${unofficial}"
