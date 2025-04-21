#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 ROCKNIX (https://github.com/ROCKNIX)
#               2021-present pkegg

. /etc/profile

set -e
set -o pipefail

### Enable logging
case $(get_setting system.loglevel) in
  verbose)
    DEBUG=true
  ;;
  *)
    DEBUG=false
  ;;
esac
DEBUG=true
### Define static values for dpad buttons and as a hat.
L2_RELEASED_EVENT="*(BTN_TL2), value 0*"
R2_RELEASED_EVENT="*(BTN_TR2), value 0*"

# strings to match errors
CONTROLLER_DISCONNECTED="*error reading: No such device"
DEVICE_DISCONNECTED="*error reading: No such device"

get_devices() {
  KJDEVS=false
  FOUNDKEYS=false
  FOUNDJOY=false
  RETRY=5
  while [ ${KJDEVS} = false ]
  do
    # Detect input devices automatically
    for DEV in /dev/input/ev*
    do
      unset SUPPORTS
      SUPPORTS=$(udevadm info ${DEV} | awk '/ID_INPUT_KEY=|ID_INPUT_JOYSTICK=/ {print $2}')
      if [ -n "${SUPPORTS}" ]
      then
        DEVICE=$(udevadm info ${DEV} | awk 'BEGIN {FS="="} /DEVNAME=/ {print $2}')
        INPUT_DEVICES+=("${DEVICE}")
        if [[ "${SUPPORTS}" =~ ID_INPUT_KEY ]]
        then
          ${DEBUG} && log $0 "Found Keyboard: ${DEVICE}"
          FOUNDKEYS=true
        elif [[ "${SUPPORTS}" =~ ID_INPUT_JOYSTICK ]]
        then
          ${DEBUG} && log $0 "Found Joystick: ${DEVICE}"
          FOUNDJOY=true
        fi
      fi
    done
    if [ "${FOUNDKEYS}" = "true" ] &&
       [ "${FOUNDJOY}" = "true" ]
    then
      ${DEBUG} && log $0 "Found all of the needed devices."
      KJDEVS=true
      break
    fi
    if [ "${RETRY}" -ge 5 ]
    then
      ${DEBUG} && log $0 "Did not find all of the needed devices, but that may be OK.  Breaking."
      break
    else
      RETRY=$(( ${RETRY} + 1 ))
    fi
    sleep 1
  done
}

get_devices

### Go into a cpu friendly loop that idles until a key is pressed.  Take action when a known pattern of keys are pressed together.
(
   for INPUT_DEVICE in ${INPUT_DEVICES[@]}
   do
     evtest "${INPUT_DEVICE}" 2>&1 &
   done
   wait
) | while read line; do
    case ${line} in
        (${CONTROLLER_DISCONNECTED})
        ${DEBUG} && log $0 "Reloading due to ${CONTROLLER_DEVICE} reattach..."
        get_devices
        ;;
        (${DEVICE_DISCONNECTED})
        ${DEBUG} && log $0 "Reloading due to ${DEVICE} reattach..."
        get_devices
        ;;
        (${L2_RELEASED_EVENT})
        swaymsg floating enable
        ;;
        (${R2_RELEASED_EVENT})
        swaymsg floating enable
        ;;
    esac
done
