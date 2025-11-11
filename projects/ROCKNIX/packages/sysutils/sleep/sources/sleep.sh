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
    "${QUIRK}" >${EVENTLOG} 2>&1
  done
}

case $1 in
  pre)
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
      log $0 "Connecting WIFI."
      nohup wifictl enable >${EVENTLOG} 2>&1
    fi

    DEVICE_VOLUME=$(get_setting "audio.volume" 2>/dev/null)
    log $0 "Restoring volume to ${DEVICE_VOLUME}%."
    amixer -c 0 -M set "${DEVICE_AUDIO_MIXER}" ${DEVICE_VOLUME}% >${EVENTLOG} 2>&1

    BRIGHTNESS=$(get_setting display.brightness)
    log $0 "Restoring brightness}."
    brightness set ${BRIGHTNESS} >${EVENTLOG} 2>&1

    BRIGHTNESS_2=$(get_setting display.brightness2)
    if [ -n "${BRIGHTNESS_2}" ]; then
        log $0 "Restoring brightness for display 2 to ${BRIGHTNESS_2}."
        brightness set 2 ${BRIGHTNESS_2} >${EVENTLOG} 2>&1
    fi

    quirks post
    ;;
esac
