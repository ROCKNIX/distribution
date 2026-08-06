#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

if [ -e "/sys/firmware/devicetree/base/model" ]; then
  QUIRK_DEVICE=$(tr -d '\0' </sys/firmware/devicetree/base/model 2>/dev/null)
fi
QUIRK_DEVICE="$(echo ${QUIRK_DEVICE} | sed -e "s#[/]#-#g")"

EVENTLOG="/var/log/sleep.log"

headphones() {
  if [ "${DEVICE_FAKE_JACKSENSE}" == "true" ]; then
    log $0 "Headphone sense: ${1}"
    systemctl ${1} headphones >${EVENTLOG} 2>&1
  fi
}

inputsense() {
  log $0 "Input sense: ${1}"
  systemctl ${1} input >${EVENTLOG} 2>&1
}

powerstate() {
  log $0 "Power state: ${1}"
  systemctl ${1} powerstate >${EVENTLOG} 2>&1
}

bluetooth() {
  if [ "$(get_setting controllers.bluetooth.enabled)" == "1" ]; then
    log $0 "Bluetooth: ${1}"
    systemctl ${1} bluetooth >${EVENTLOG} 2>&1
  fi
}

modules() {
  log $0 "Modules: ${1}"
  case ${1} in
    stop)
      if [ -e "/usr/config/modules.bad" ]; then
        for module in $(cat /usr/config/modules.bad); do
          EXISTS=$(lsmod | grep ${module})
          if [ $? = 0 ]; then
            echo ${module} >>/tmp/modules.load
            modprobe -r ${module} >${EVENTLOG} 2>&1
          fi
        done
      fi
      ;;
    start)
      if [ -e "/tmp/modules.load" ]; then
        for module in $(cat /tmp/modules.load); do
          MODCNT=0
          MODATTEMPTS=10
          while true; do
            if (( "${MODCNT}" < "${MODATTEMPTS}" )); then
              modprobe ${module%% *} >${EVENTLOG} 2>&1
              if [ $? = 0 ]; then
                break
              fi
            else
              break
            fi
            MODCNT=$((${MODCNT} + 1))
            sleep .5
          done
        done
        rm -f /tmp/modules.load
      fi
      ;;
  esac
}

quirks() {
  for QUIRK in /usr/lib/autostart/quirks/platforms/"${HW_DEVICE}"/sleep.d/${1}/* \
               /usr/lib/autostart/quirks/devices/"${QUIRK_DEVICE}"/sleep.d/${1}/*; do
    [ -x "${QUIRK}" ] || continue
    "${QUIRK}" >${EVENTLOG} 2>&1
  done
}

# rfkill returns as soon as the block is queued and the driver tears down
# asynchronously, so the freezer otherwise races it. ath12k cares: its resume
# path only does its work when the radio was already down. Skipped where no
# wlan rfkill switch is registered, since the block did nothing to wait for.
wifi_wait_down() {
  local dev flags tries

  dev=$(ls /sys/class/net 2>/dev/null | grep -m1 ^wlan)
  [ -z "${dev}" ] && return 0
  grep -qx wlan /sys/class/rfkill/*/type 2>/dev/null || return 0

  for tries in $(seq 1 30); do
    flags=$(cat "/sys/class/net/${dev}/flags" 2>/dev/null) || return 0
    [ -z "${flags}" ] && return 0
    (( flags & 1 )) || return 0
    sleep .1
  done
  log $0 "WIFI interface ${dev} still up after 3s, suspending anyway."
}

case $1 in
  pre)
    if [ "$(get_setting wifi.enabled)" == "1" ]; then
      # while still associated, so resume rejoins this network and not
      # whichever saved profile NM happens to pick first
      log $0 "Preferring the active WIFI network on reconnect."
      wifictl pin >${EVENTLOG} 2>&1

      log $0 "Disabling WIFI."
      wifictl disable >${EVENTLOG} 2>&1
      wifi_wait_down
    fi

    headphones stop
    inputsense stop
    bluetooth stop
    powerstate stop
    modules stop
    quirks pre
    touch /run/.last_sleep_time
    ;;
  post)
    ledcontrol
    modules start
    powerstate start
    headphones start
    inputsense start
    bluetooth start

    if [ "$(get_setting wifi.enabled)" == "1" ]; then
      # NetworkManager only learns the system is awake after these hooks
      # finish, so the radio has to stay blocked until it does. Detached
      # because that wait must not hold up the rest of the resume.
      log $0 "Enabling WIFI once NetworkManager reports it is awake."
      # A helper from an earlier resume can still be waiting, and its unit name
      # would make this systemd-run fail silently, leaving the radio blocked.
      systemctl stop wifi-resume.service >${EVENTLOG} 2>&1
      systemd-run --no-block --collect --unit=wifi-resume /usr/bin/wifi-resume >${EVENTLOG} 2>&1
    fi

    DEVICE_VOLUME=$(get_setting "audio.volume" 2>/dev/null)
    log $0 "Restoring volume to ${DEVICE_VOLUME}%."
    amixer -c 0 -M set "${DEVICE_AUDIO_MIXER}" ${DEVICE_VOLUME}% >${EVENTLOG} 2>&1

    BRIGHTNESS=$(get_setting display.brightness)
    log $0 "Restoring brightness to ${BRIGHTNESS}."
    brightness set ${BRIGHTNESS} >${EVENTLOG} 2>&1

    BRIGHTNESS_2=$(get_setting display.brightness2)
    if [ -n "${BRIGHTNESS_2}" ]; then
        log $0 "Restoring brightness for display 2 to ${BRIGHTNESS_2}."
        brightness set 2 ${BRIGHTNESS_2} >${EVENTLOG} 2>&1
    fi

    quirks post
    ;;
esac
