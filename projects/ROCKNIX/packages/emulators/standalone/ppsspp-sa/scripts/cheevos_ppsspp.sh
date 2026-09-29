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

# Check if RetroAchievements are enabled in Emulation Station. Quoted: an
# empty read used to make the test a syntax error that fell through to
# "enabled" (audit #186 PL-31).
if [ "${enabled}" != "1" ]; then
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
hardcore_raw="${hardcore}"
if [ "${hardcore}" = 1 ]; then
  hardcore="True"
else
  hardcore="False"
fi

# OFFLINE RETROACHIEVEMENTS (fork #165, D-RA-002): PPSSPP's own achievements
# client behind AchievementsHost, pointed at the RAOfflineProxy service on
# loopback when the toggle is on, hardcore is off (the proxy refuses hardcore
# awards) and the port answers -- a host with nothing behind it would disable
# achievements for the session. Empty otherwise, which is PPSSPP's default
# host: this file travels in a settings backup, so a restored device with the
# toggle off must find the line cleared, not pointing at a dead port.
# PPSSPP reads the key from ppsspp.ini's [Achievements] (Core/Config.cpp:376
# at the pinned v1.20.2, afbc66a3) and, when it is not empty, hands it to
# rcheevos as the host (rc_client_set_host, Core/RetroAchievements.cpp:650-652)
# -- "a custom host, only useful for debugging against non-prod RA
# environments" in its own words, which is what the proxy is (#308 F-EM-07).
# Routed only when hardcore READ as off ("0" -- raofflineproxy-ctl enable
# writes the key), never when it read as nothing: an empty answer is a key
# that could not be read as much as one that is unset, and the proxy
# refuses hardcore awards, so unknown keeps the direct path (#186 PL-31).
#
# Whether the proxy is listening is read from the kernel's socket tables with
# bash's own read, not from netstat, which nothing PPSSPP ships declares and
# whose absence read as "nothing answers" (#308 F-EM-04): 127.0.0.1, 0.0.0.0
# or ::ffff:127.0.0.1 on port 8080 (1F90) in state LISTEN (0A) -- the
# listeners that take the IPv4 connection to 127.0.0.1:8080 PPSSPP is
# given. ::1 does not take it, and :: may be IPv6-only, which the table does
# not say, so neither counts (audit of the fixes, gpt G-D-02, gpt G-F2-02).
# That turns the proxy away never: its sockets are IPv4 (AF_INET in the
# client's proxy_service.py and boot.py), and the scripts suite holds this
# check and raofflineproxy-ctl's to the pinned client's own socket (audit of
# the fix round, claude G2-D-01, PL-033).
# 0 listening, 1 not, 2 when neither table could be read -- said apart in the
# log, since "couldn't tell" is not "nothing there". RAOFFLINEPROXY_PROC_NET
# stands in for /proc/net in the scripts suite, as it does for
# raofflineproxy-ctl listening.
proxy_listening() {
  local proc="${RAOFFLINEPROXY_PROC_NET:-/proc/net}" f readable=0 sl addr rem st rest
  for f in "${proc}/tcp" "${proc}/tcp6"; do
    [ -r "${f}" ] || continue
    readable=1
    while read -r sl addr rem st rest; do
      [ "${st}" = "0A" ] || continue
      case "${addr}" in
        0100007F:1F90|00000000:1F90|0000000000000000FFFF00000100007F:1F90) return 0 ;;
      esac
    done < "${f}"
  done
  [ "${readable}" -eq 1 ] && return 1
  return 2
}

host=""
if [ "$(get_setting "global.retroachievements.offlineproxy")" = 1 ] && [ "${hardcore_raw}" = "0" ]; then
  proxy_listening
  case $? in
    0) host="127.0.0.1:8080" ;;
    1) echo "Offline RetroAchievements is on but nothing is listening on 127.0.0.1:8080; launching direct." >> ${LOG_FILE} ;;
    *) echo "Offline RetroAchievements is on but this device couldn't tell whether the offline service is listening; launching direct." >> ${LOG_FILE} ;;
  esac
fi

# Update emulator config with RetroAchievements settings
zcheevos=$(grep -Fx "[Achievements]" ${PPSSPP_INI})
echo "${token}" > ${PPSSPP_ACHIEVEMENTS}

if [ -z "${zcheevos}" ]
then
    echo -e "[Achievements]\nAchievementsEnable = True\nAchievementsUserName = ${username}\nAchievementsChallengeMode = ${hardcore}\nAchievementsHost = ${host}" >> ${PPSSPP_INI}
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

    # Matched up to the "=", not past it: an empty value is written as
    # "AchievementsHost = " and PPSSPP may save it back without the space.
    if ! grep -q "^AchievementsHost =" ${PPSSPP_INI}; then
        sed -i "/^\[Achievements\]/a AchievementsHost = ${host}" ${PPSSPP_INI}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^AchievementsHost =.*/AchievementsHost = ${host}/;}" ${PPSSPP_INI}
    fi
fi
