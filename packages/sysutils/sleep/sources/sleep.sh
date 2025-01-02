#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

if [ -e "/sys/firmware/devicetree/base/model" ]
then
  QUIRK_DEVICE=$(tr -d '\0' </sys/firmware/devicetree/base/model 2>/dev/null)
else
  QUIRK_DEVICE="$(tr -d '\0' </sys/class/dmi/id/sys_vendor 2>/dev/null) $(tr -d '\0' </sys/class/dmi/id/product_name 2>/dev/null)"
fi
QUIRK_DEVICE="$(echo ${QUIRK_DEVICE} | sed -e "s#[/]#-#g")"

EVENTLOG="/var/log/sleep.log"

headphones() {
  if [ "${DEVICE_FAKE_JACKSENSE}" == "true" ]
  then
    log $0 "Headphone sense: ${1}"
    systemctl ${1} headphones >${EVENTLOG} 2>&1
  fi
}

inputsense() {
    log $0 "Input sense: ${1}"
    systemctl ${1} input >${EVENTLOG} 2>&1
}

powerstate() {
  if [ "$(get_setting system.powersave)" = 1 ]
  then
    systemctl ${1} powerstate >${EVENTLOG} 2>&1
  fi
}

bluetooth() {
  if [ "$(get_setting controllers.bluetooth.enabled)" == "1" ]
  then
    log $0 "Bluetooth: ${1}"
    systemctl ${1} bluetooth >${EVENTLOG} 2>&1
  fi
}

modules() {
  log $0 "Modules: ${1}"
  case ${1} in
    stop)
      if [ -e "/usr/config/modules.bad" ]
      then
        for module in $(cat /usr/config/modules.bad)
        do
          EXISTS=$(lsmod | grep ${module})
          if [ $? = 0 ]
          then
            echo ${module} >>/tmp/modules.load
            modprobe -r ${module} >${EVENTLOG} 2>&1
          fi
        done
      fi
    ;;
    start)
      if [ -e "/tmp/modules.load" ]
      then
        for module in $(cat /tmp/modules.load)
        do
          MODCNT=0
          MODATTEMPTS=10
          while true
          do
            if (( "${MODCNT}" < "${MODATTEMPTS}" ))
            then
              modprobe ${module%% *} >${EVENTLOG} 2>&1
              if [ $? = 0 ]
              then
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
               /usr/lib/autostart/quirks/devices/"${QUIRK_DEVICE}"/sleep.d/${1}/*
  do
    "${QUIRK}" >${EVENTLOG} 2>&1
  done
}

case $1 in
  pre)
    headphones stop
    inputsense stop
    bluetooth stop
    runtime_power_management on
    wake_events disabled
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

    if [ "$(get_setting wifi.enabled)" == "1" ]
    then
      log $0 "Connecting WIFI."
      nohup wifictl enable >${EVENTLOG} 2>&1
    fi

    DEVICE_VOLUME=$(get_setting "audio.volume" 2>/dev/null)
    log $0 "Restoring volume to ${DEVICE_VOLUME}%."
    amixer -c 0 -M set "${DEVICE_AUDIO_MIXER}" ${DEVICE_VOLUME}% >${EVENTLOG} 2>&1

    BRIGHTNESS=$(get_setting display.brightness)
    log $0 "Restoring brightness to ${BRIGHTNESS}."
    brightness set ${BRIGHTNESS} >${EVENTLOG} 2>&1
    quirks post
  ;;
esac
