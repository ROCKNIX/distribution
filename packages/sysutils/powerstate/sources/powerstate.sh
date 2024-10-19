#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

###
### Normally this would be a udev rule, but some devices like the AyaNeo Air
### do not properly report the applied power state to udev, and we can't use
### inotifyd to watch the status in /sys.
###

. /etc/profile

BATCNT=0
unset CURRENT_MODE
unset AC_STATUS
ledcontrol $(get_setting led.color)

while true
do
  AC_STATUS="$(cat /sys/class/power_supply/[bB][aA][tT]*/status 2>/dev/null)"
  if [[ ! "${CURRENT_MODE}" =~ ${AC_STATUS} ]]
  then
    case ${AC_STATUS} in
      Disch*)
        if [ "$(get_setting system.powersave)" = 1 ]
        then
          log $0 "Switching to battery mode."
          if [ -e "/tmp/.gpu_performance_level" ]
          then
            GPUPROFILE=$(cat /tmp/.gpu_performance_level)
          else
            GPUPROFILE=$(get_setting system.gpuperf)
          fi
          if [ -z "${GPUPROFILE}" ]
          then
            GPUPROFILE="auto"
          fi
          audio_powersave 1
          cpu_perftune battery
          gpu_performance_level ${GPUPROFILE}
          pcie_aspm_policy powersave
          wake_events enabled
          runtime_power_management auto 5
          scsi_link_power_management med_power_with_dipm
        fi
        if [ "${DEVICE_LED_CHARGING}" = "true" ]
        then
          ledcontrol discharging
        fi
      ;;
      *)
        if [ "$(get_setting system.powersave)" = 1 ]
        then
          log $0 "Switching to performance mode."
          audio_powersave 0
          cpu_perftune performance
          gpu_performance_level auto
          pcie_aspm_policy default
          wake_events disabled
          runtime_power_management on 0
          scsi_link_power_management ""
        fi
        if [ "${DEVICE_LED_CHARGING}" = "true" ]
        then
          ledcontrol charging
        fi
      ;;
    esac
    /usr/bin/wifictl setpowersave
    CURRENT_MODE="${AC_STATUS}"
  fi
  ### Until we have an overlay. :rofl:
  BATLEFT=$(battery_percent)
  if (( "${BATCNT}" >= "20" )) &&
     [[ "${AC_STATUS}" =~ Disch ]]
  then
    AUDIBLEALERT=$(get_setting system.battery.warning)
    if (( ${BATLEFT} < "26" ))
    then
      if [ "${DEVICE_LED_CONTROL}" = "true" ]  &&  [ ! "${DEVICE_BATTERY_LED_STATUS}" = "true" ]
      then
        # Flash the RGB or power LED if available.
        led_flash
        BATCNT=0
      elif [ "${AUDIBLEALERT}" = "1" ]
      then
        say "BATTERY AT ${BATLEFT}%"
        BATCNT=0
      fi
    fi
  elif (( "${BATLEFT}" > "97" ))
  then
    if [ "${DEVICE_LED_CHARGING}" = "true" ]
    then
      # Reset the LED as if the battery was full.
      ledcontrol discharging
    fi
  fi
  BATCNT=$(( ${BATCNT} + 1 ))
  sleep 2
done
