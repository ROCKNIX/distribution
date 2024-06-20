#!/bin/bash

#load some built-in useful functions
. /etc/profile.d/001-functions

AUDIO_V_DEVICE_SETTING_KEY="audio.v-driver"

get_current_driver() {
  CONFDRIVER=$(get_setting ${AUDIO_V_DEVICE_SETTING_KEY})

  if [ -z ${CONFDRIVER} ]; then
    CONFDRIVER="stereo"	#default to stereo
    set_setting ${AUDIO_V_DEVICE_SETTING_KEY} ${CONFDIRVER}
  fi
}

load_driver() {
  DRIVER_TO_LOAD=$1
  case ${DRIVER_TO_LOAD} in 
    "stereo")
      number=$(wpctl status | grep -m 1 "Stereo Playback Device" | grep -Eo '[0-9]+' | awk 'NR==1{print; exit}')
        ;;
    "mono")
      number=$(wpctl status | grep -m 1 "Mono Playback Device" | grep -Eo '[0-9]+' | awk 'NR==1{print; exit}')
        ;;
    *)
      exit 3
        ;;
  esac

  # Check if the number is extracted successfully
  if [ -n "$number" ]; then
    # Set the default with the extracted number
    wpctl set-default "$number"
    echo "Default set to $number"
  else
    echo "Error: Unable to extract number from command output."
  fi
}

case "$1" in
  "--options")
    echo "stereo mono"
    ;;
  "--start")
    get_current_driver
    load_driver ${CONFDRIVER}
    ;;
  "stereo" | "mono")
    set_setting ${AUDIO_V_DEVICE_SETTING_KEY} $1
    get_current_driver
    echo ${CONFDRIVER}
    load_driver ${CONFDRIVER}
    ;;
  "")
    get_current_driver
    echo ${CONFDRIVER}
    ;;
  *)
    echo "Unexpected parameter $1" >&2
    echo "Usage:" >&2
    echo "  List available drivers:                $0 --options" >&2
    echo "  Load configured driver and set libs:   $0 --start" >&2
    echo "  Get current driver:                    $0" >&2
    echo "  Configure driver to load immediately:  $0 <stereo|mono>" >&2
    exit 1
    ;;
esac
