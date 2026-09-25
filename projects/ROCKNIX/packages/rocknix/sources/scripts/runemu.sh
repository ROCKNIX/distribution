#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# Source predefined functions and variables
. /etc/profile
. /etc/os-release

### Switch to performance mode early to speed up configuration and reduce time it takes to get into games.
performance

# Command line schema
# $1 = Game/Port
# $2 = Platform
# $3 = Core
# $4 = Emulator

ARGUMENTS="$@"
PLATFORM="${ARGUMENTS##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found
CORE="${ARGUMENTS##*--core=}"  # read from --core= onwards
CORE="${CORE%% *}"  # until a space is found
EMULATOR="${ARGUMENTS##*--emulator=}"  # read from --emulator= onwards
EMULATOR="${EMULATOR%% *}"  # until a space is found
ROMNAME="$1"
BASEROMNAME=${ROMNAME##*/}
GAMEFOLDER="${ROMNAME//${BASEROMNAME}}"

### Define the variables used throughout the script
BLUETOOTH_STATE=$(get_setting controllers.bluetooth.enabled)
ES_CONFIG="/storage/.emulationstation/es_settings.cfg"
VERBOSE=false
LOG_DIRECTORY="/var/log"
LOG_FILE="exec.log"
RUN_SHELL="/usr/bin/bash"
RETROARCH_TEMP_CONFIG="/storage/.config/retroarch/retroarch.cfg"
RETROARCH_APPEND_CONFIG="/tmp/.retroarch.cfg"
NETWORK_PLAY="No"
SET_SETTINGS_TMP="/tmp/shader"
OUTPUT_LOG="${LOG_DIRECTORY}/${LOG_FILE}"
SCRIPT_NAME=$(basename "$0")

### Export Game Guide Path
GAME_GUIDE_PATH_CHECK="${1%.*}.txt"
if [ ! -f "${GAME_GUIDE_PATH_CHECK}" ]; then
  GAME_GUIDE_PATH_CHECK="No Game Guide Found"
fi
  /usr/bin/game-guides-tool "${1}"

### Function Library
function log() {
        if [ ${LOG} == true ]
        then
                if [[ ! -d "$LOG_DIRECTORY" ]]
                then
                        mkdir -p "$LOG_DIRECTORY"
                fi
                echo "${SCRIPT_NAME}: $*" 2>&1 | tee -a ${LOG_DIRECTORY}/${LOG_FILE}
        else
                echo "${SCRIPT_NAME}: $*"
        fi
}

function loginit() {
        if [ ${LOG} == true ]
        then
                if [ -e ${LOG_DIRECTORY}/${LOG_FILE} ]
                then
                        rm -f ${LOG_DIRECTORY}/${LOG_FILE}
                fi
                cat <<EOF >${LOG_DIRECTORY}/${LOG_FILE}
Emulation Run Log - Started at $(date)

ARG1: $1
ARG2: $2
ARG3: $3
ARG4: $4
ARGS: $*
EMULATOR: ${EMULATOR}
PLATFORM: ${PLATFORM}
CORE: ${CORE}
ROM NAME: ${ROMNAME}
BASE ROM NAME: ${ROMNAME##*/}
USING CONFIG: ${RETROARCH_TEMP_CONFIG}
USING APPENDCONFIG : ${RETROARCH_APPEND_CONFIG}
GAME GUIDE PATH: ${GAME_GUIDE_PATH_CHECK}

EOF
        else
                log $0 "Emulation Run Log - Started at $(date)"
        fi
}

function quit() {
        ${VERBOSE} && log $0 "Cleaning up and exiting"
        bluetooth enable
        set_kill set "emulationstation"
        clear_screen
        DEVICE_CPU_GOVERNOR=$(get_setting system.cpugovernor)
        ${DEVICE_CPU_GOVERNOR}
        exit $1
}

function clear_screen() {
        ${VERBOSE} && log $0 "Clearing screen"
        clear
}

function bluetooth() {
        if [ "$1" == "disable" ]
        then
                ${VERBOSE} && log $0 "Disabling BT"
                if [[ "${BLUETOOTH_STATE}" == "1" ]]
                then
                        NPID=$(pgrep -f rocknix-bluetooth-agent)
                        if [[ ! -z "$NPID" ]]; then
                                kill "$NPID"
                        fi
                fi
        elif [ "$1" == "enable" ]
        then
                ${VERBOSE} && log $0 "Enabling BT"
                if [[ "${BLUETOOTH_STATE}" == "1" ]]
                then
                        systemd-run rocknix-bluetooth-agent
                fi
        fi
}

### Enable logging
case $(get_setting system.loglevel) in
  off|none)
    LOG=false
  ;;
  verbose)
    LOG=true
    VERBOSE=true
  ;;
  *)
    LOG=true
  ;;
esac

### Prepare to load our emulator and game.
loginit "$1" "$2" "$3" "$4"
clear_screen
bluetooth disable
set_kill stop

### Determine which emulator we're launching and make appropriate adjustments before launching.
${VERBOSE} && log $0 "Configuring for ${EMULATOR}"
case ${EMULATOR} in
  mednafen)
    set_kill set "-9 mednafen"
    RUNTHIS='${RUN_SHELL} /usr/bin/start_mednafen.sh "${ROMNAME}" "${CORE}" "${PLATFORM}"'
  ;;
  retroarch)
    # Make sure NETWORK_PLAY isn't defined before we start our tests/configuration.
    del_setting netplay.mode

    case ${ARGUMENTS} in
      *"--host"*)
        ${VERBOSE} && log $0 "Setup netplay host."
        NETWORK_PLAY="${ARGUMENTS##*--host}"  # read from --host onwards
        NETWORK_PLAY="${NETWORK_PLAY%%--nick*}"  # until --nick is found
        NETWORK_PLAY="--host ${NETWORK_PLAY} --nick"
        set_setting netplay.mode "host"
      ;;
      *"--connect"*)
        ${VERBOSE} && log $0 "Setup netplay client."
        NETWORK_PLAY="${ARGUMENTS##*--connect}"  # read from --connect onwards
        NETWORK_PLAY="${NETWORK_PLAY%%--nick*}"  # until --nick is found
        NETWORK_PLAY="--connect ${NETWORK_PLAY} --nick"
        set_setting netplay.mode "client"
      ;;
      *"--netplaymode spectator"*)
        ${VERBOSE} && log $0 "Setup netplay spectator."
        set_setting "netplay.mode" "spectator"
      ;;
    esac

    ### Set set_kill to kill the appropriate retroarch
    set_kill set "retroarch retroarch32"

    ### Assume we're running 64bit Retroarch
    RABIN="retroarch"

    case ${HW_ARCH} in
      aarch64)
        if [[ "${CORE}" =~ pcsx_rearmed32 ]] || \
           [[ "${CORE}" =~ gpsp ]] || \
           [[ "${CORE}" =~ desmume ]]
        then
          ### Configure for 32bit Retroarch
          ${VERBOSE} && log $0 "Configuring for 32bit cores."
          export RABIN="retroarch32"
        fi
      ;;
    esac


    ### Configure specific emulator requirements
    case ${CORE} in
      freej2me*)
        ${VERBOSE} && log $0 "Setup freej2me requirements."
        /usr/bin/freej2me.sh
        JAVA_HOME='/storage/jdk'
        export JAVA_HOME
        PATH="$JAVA_HOME/bin:$PATH"
        export PATH
        export _JAVA_OPTIONS="-Djava.awt.headless=true"
      ;;
      easyrpg*)
        # easyrpg needs runtime files to be downloaded on the first run
        ${VERBOSE} && log $0 "Setup easyrpg requirements."
        /usr/bin/easyrpg.sh
      ;;
    esac


    RUNTHIS='${EMUPERF} /usr/bin/${RABIN} -L /tmp/cores/${CORE}_libretro.so --config ${RETROARCH_TEMP_CONFIG} --appendconfig ${RETROARCH_APPEND_CONFIG} "${ROMNAME}"'

    CONTROLLERCONFIG="${ARGUMENTS#*--controllers=*}"

    if [[ "${ARGUMENTS}" == *"-state_slot"* ]]
    then
      CONTROLLERCONFIG="${CONTROLLERCONFIG%% -state_slot*}"  # until -state is found
      SNAPSHOT="${ARGUMENTS#*-state_slot *}" # -state_slot x
      SNAPSHOT="${SNAPSHOT%% -*}"
        if [[ "${ARGUMENTS}" == *"-autosave"* ]]; then
          CONTROLLERCONFIG="${CONTROLLERCONFIG%% -autosave*}"  # until -autosave is found
          AUTOSAVE="${ARGUMENTS#*-autosave *}" # -autosave x
          AUTOSAVE="${AUTOSAVE%% -*}"
        else
          AUTOSAVE=""
        fi
    else
      CONTROLLERCONFIG="${CONTROLLERCONFIG%% --*}"  # until a -- is found
      SNAPSHOT=""
      AUTOSAVE=""
    fi

    # Configure platform specific requirements
    case ${PLATFORM} in
      "atomiswave")
        rm ${ROMNAME}.nvmem*
      ;;
      "scummvm")
        GAMEDIR=$(cat "${ROMNAME}" | awk 'BEGIN {FS="\""}; {print $2}')
        cd "${GAMEDIR}"
        RUNTHIS='${RUN_SHELL} /usr/bin/start_scummvm.sh libretro .'
      ;;
    esac

    ### Configure retroarch
    if [ -e "${SET_SETTINGS_TMP}" ]
    then
      rm -f "${SET_SETTINGS_TMP}"
    fi
    ${VERBOSE} && log $0 "Execute setsettings (${PLATFORM} ${ROMNAME} ${CORE} --controllers=${CONTROLLERCONFIG} --autosave=${AUTOSAVE} --snapshot=${SNAPSHOT})"
    (/usr/bin/setsettings.sh "${PLATFORM}" "${ROMNAME}" "${CORE}" --controllers="${CONTROLLERCONFIG}" --autosave="${AUTOSAVE}" --snapshot="${SNAPSHOT}" >${SET_SETTINGS_TMP})

    ### Enable RetroArch Network Control for this session on dual-screen devices
    ### so the bottom-screen UI can forward save-state / load-state / resume commands.
    if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
      echo 'network_cmd_enable = "true"' >> "${RETROARCH_APPEND_CONFIG}"
      echo 'network_cmd_port = "55355"'  >> "${RETROARCH_APPEND_CONFIG}"
      echo 'savestate_thumbnail_enable = "true"' >> "${RETROARCH_APPEND_CONFIG}"
      echo 'cheevos_custom_host = "http://127.0.0.1:4874"' >> "${RETROARCH_APPEND_CONFIG}"

      if ! pgrep -f 'python3 .*/lowerdeck/ra_proxy\.py' >/dev/null 2>&1; then
        ( python3 /usr/share/lowerdeck/ra_proxy.py >/dev/null 2>&1 ) &
        for _ in 1 2 3 4 5 6 7 8 9 10; do
          netstat -ln 2>/dev/null | grep -q ':4874 ' && break
          sleep 0.1
        done
      fi
    fi

    ### If setsettings wrote data in the background, grab it and assign it to EXTRAOPTS
    if [ -e "${SET_SETTINGS_TMP}" ]
    then
      EXTRAOPTS=$(cat ${SET_SETTINGS_TMP})
      rm -f ${SET_SETTINGS_TMP}
      ${VERBOSE} && log $0 "Extra Options: ${EXTRAOPTS}"
    fi

    if [[ ${EXTRAOPTS} != 0 ]]; then
      RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${EXTRAOPTS} --config|")
    fi
  ;;
  *)
    case ${PLATFORM} in
      "setup")
        RUNTHIS='${RUN_SHELL} "${ROMNAME}"'
      ;;
      "gamecube"|"triforce")
        RUNTHIS='${RUN_SHELL} /usr/bin/start_dolphin_gc.sh "${ROMNAME}" "${PLATFORM}" "${CORE}"'
      ;;
      "wii"|"wiiware")
        RUNTHIS='${RUN_SHELL} /usr/bin/start_dolphin_wii.sh "${ROMNAME}" "${PLATFORM}" "${CORE}"'
      ;;
      "ports")
      if [[ "${ROMNAME,,}" == *".appimage" ]]; then
        RUNTHIS='${EMUPERF} "${ROMNAME}"'
      else
        RUNTHIS='${EMUPERF} ${RUN_SHELL} "${ROMNAME}"'
      fi
        chmod +x "${ROMNAME}"
        sed -i "/^ACTIVE_GAME=/c\ACTIVE_GAME=\"${ROMNAME}\"" /storage/.config/PortMaster/mapper.txt
        sed -i "/^ACTIVE_PLATFORM=/c\ACTIVE_PLATFORM=\"${PLATFORM}\"" /storage/.config/PortMaster/mapper.txt
      ;;
      "windows")
        RUNTHIS='${EMUPERF} ${RUN_SHELL} "${ROMNAME}"'
        # Hook into Portmaster control mapping
        sed -i "/^ACTIVE_GAME=/c\ACTIVE_GAME=\"${ROMNAME}\"" /storage/.config/PortMaster/mapper.txt
        sed -i "/^ACTIVE_PLATFORM=/c\ACTIVE_PLATFORM=\"${PLATFORM}\"" /storage/.config/PortMaster/mapper.txt
      ;;
      "shell")
        RUNTHIS='${RUN_SHELL} "${ROMNAME}"'
      ;;
      *)
        RUNTHIS='${RUN_SHELL} "/usr/bin/start_${CORE%-*}.sh" "${ROMNAME}" "${PLATFORM}"'
      ;;
    esac
  ;;
esac

### Execution time.
clear_screen
${VERBOSE} && log $0 "executing game: ${ROMNAME}"
${VERBOSE} && log $0 "script to execute: ${RUNTHIS}"

### Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${ROMNAME##*/}")
${VERBOSE} && log $0 "Configure big.little (${CORES})"
case ${CORES} in
  little)
    EMUPERF="${SLOW_CORES}"
  ;;
  big)
    EMUPERF="${FAST_CORES}"
  ;;
  *)
    unset EMUPERF
  ;;
esac

### We need the original system cooling profile later so get it now!
COOLINGPROFILE=$(get_setting cooling.profile)

### Configure GPU performance mode
GPUPERF=$(get_setting "gpuperf" "${PLATFORM}" "${ROMNAME##*/}")
if [ ! -z ${GPUPERF} ]
then
  ${VERBOSE} && log $0 "Set GPU performance to (${GPUPERF})"
  gpu_performance_level ${GPUPERF}
  get_gpu_performance_level >/tmp/.gpu_performance_level
fi

if [ "${DEVICE_HAS_FAN}" = "true" ]
then
  ### Set any custom fan profile (make this better!)
  GAMEFAN=$(get_setting "cooling.profile" "${PLATFORM}" "${ROMNAME##*/}")
  if [ ! -z "${GAMEFAN}" ]
  then
    ${VERBOSE} && log $0 "Set fan profile to (${GAMEFAN})"
    set_setting cooling.profile ${GAMEFAN}
    systemctl restart fancontrol
  fi
fi

### Display mode for emulation
DISPLAY_MODE=$(get_setting "display_mode" "${PLATFORM}" "${ROMNAME##*/}")
if [ ! -z "${DISPLAY_MODE}" ] && [ "${DISPLAY_MODE}" != "default" ]
then
  set_refresh_rate "${DISPLAY_MODE}"
fi

FORCEPACK=$(get_setting "forcepack" "${PLATFORM}" "${ROMNAME##*/}")
if [ ! -z "${FORCEPACK}" ] && [ "${FORCEPACK}" = "On" ]
then
    ${VERBOSE} && log $0 "Enabling panfrost forcepack"
    export PAN_MESA_DEBUG=forcepack
fi

### Offline all but the number of threads we need for this game if configured.
NUMTHREADS=$(get_setting "threads" "${PLATFORM}" "${ROMNAME##*/}")
if [ -n "${NUMTHREADS}" ] &&
   [ ! ${NUMTHREADS} = "default" ]
then
  ${VERBOSE} && log $0 "Configure active cores (${NUMTHREADS})"
  onlinethreads ${NUMTHREADS} 0
fi

### Set the governor mode for emulation
CPU_GOVERNOR=$(get_setting "cpugovernor" "${PLATFORM}" "${ROMNAME##*/}")
${VERBOSE} && log $0 "Set emulation performance mode to (${CPU_GOVERNOR})"
${CPU_GOVERNOR}

### Check whether MangoHud is supported and enabled
if [ "${DEVICE_MANGOHUD_SUPPORT}" == "true" ]; then
  MANGOHUD_ENABLED=$(get_setting "rocknix.mangohud.enabled"  "${PLATFORM}" "${ROMNAME##*/}")
  if [ "${MANGOHUD_ENABLED}" = "1" ]; then
    # Enable GPU profiling and MangoHud
    gpu_profiling "on"
    RUNTHIS="/usr/bin/mangohud ${RUNTHIS}"
    ${VERBOSE} && log $0 "Enabling MangoHud"
  fi
fi

scaling_setting() {
  get_setting "rocknix.scaling.$1" "${PLATFORM}" "${ROMNAME##*/}"
}
scaling_dpu_knobs() {
  # dpu_de_unscaled keeps the scaler on at 1:1 so an unscaled plane is sharpened too.
  local P=${DEVICE_SCANOUT_SHARPNESS}
  [ -d "${P}" ] || return
  [ "${SCALING_FILTER}" = "hardware_nearest" ] && echo Y > "${P}/dpu_nearest" 2>/dev/null \
                                              || echo N > "${P}/dpu_nearest" 2>/dev/null
  if [ "${SCALING_FILTER}" = "hardware_edge" ]; then
    echo Y > "${P}/dpu_de_dir" 2>/dev/null
    echo "${SCALING_EDGE}" > "${P}/dpu_de_dir_weight" 2>/dev/null
  else
    echo N > "${P}/dpu_de_dir" 2>/dev/null
  fi
  if [ "${SCALING_SHARPNESS}" -gt 0 ]; then
    echo Y > "${P}/dpu_de" 2>/dev/null
    echo $(( SCALING_SHARPNESS * 12 / 5 )) > "${P}/dpu_de_sharpen1" 2>/dev/null
    echo $(( SCALING_SHARPNESS * 12 / 5 )) > "${P}/dpu_de_sharpen2" 2>/dev/null
    echo Y > "${P}/dpu_de_unscaled" 2>/dev/null
  else
    echo N > "${P}/dpu_de" 2>/dev/null
  fi
  ${VERBOSE} && log $0 "Display filter ${SCALING_FILTER} (edge ${SCALING_EDGE}), sharpening level ${SCALING_SHARPNESS}"
}
scanout_reset_stale
if [ "${DEVICE_SCANOUT_SCALING}" = "true" ] && [ "${PLATFORM}" != "steam" ] && [ "${PLATFORM}" != "heroic" ]; then
  # Reset after the game, or by the trap on an early exit
  scanout_claim
  trap scanout_reset EXIT

  eval "$(swaymsg -t get_outputs | jq -r '
    (.[] | select(.focused == true) |
    "OUTPUT_W=\(.current_mode.width) OUTPUT_H=\(.current_mode.height) OUTPUT_TRANSFORM=\(.transform) OUTPUT_NAME=\(.name)"),
    (first(.[] | select(.focused != true and .active == true)) | "OUTPUT2_NAME=\(.name)")
  ')"

  prerotate_env "${OUTPUT_TRANSFORM}"
  ${VERBOSE} && log $0 "Pre-rotation ${vk_wsi_wayland_prerotate:-none} (output ${OUTPUT_TRANSFORM})"

  SCALING_SHARPNESS=$(scaling_setting sharpness)
  case ${SCALING_SHARPNESS} in
    [0-9]|10) ;;
    *) SCALING_SHARPNESS=0 ;;
  esac
  SCALING_FILTER=$(scaling_setting filter)
  case ${SCALING_FILTER} in
    hardware_nearest|hardware_edge) ;;
    *) SCALING_FILTER=hardware ;;
  esac
  SCALING_EDGE=$(scaling_setting edge)
  case ${SCALING_EDGE} in
    [0-9]|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]) ;;
    *) SCALING_EDGE=32 ;;
  esac
  scaling_dpu_knobs

  SCALING_RENDER=$(scaling_setting render)
  if [ -n "${SCALING_RENDER}" ] && [ "${SCALING_RENDER}" != "off" ] && [ -n "${OUTPUT_W}" ] && [ -n "${OUTPUT_H}" ]; then
    SCALING_W=${OUTPUT_W}
    SCALING_H=${OUTPUT_H}
    case ${OUTPUT_TRANSFORM} in
      90|270|flipped-90|flipped-270)
        SCALING_W=${OUTPUT_H}; SCALING_H=${OUTPUT_W}
      ;;
    esac
    # Native heights for launchers that don't report their image
    case ${PLATFORM} in
      dreamcast|naomi|atomiswave|xbox) NATIVE_H=480 ;;
      n64|saturn|psx)                  NATIVE_H=240 ;;
      ps2)                             NATIVE_H=448 ;;
      gamecube|wii)                    NATIVE_H=480 ;;
      psp)                             NATIVE_H=272 ;;
      nds)                             NATIVE_H=384 ;;
      3ds)                             NATIVE_H=480 ;;
      psvita)                          NATIVE_H=544 ;;
      *)                               NATIVE_H="" ;;
    esac
    SCALING_MAX=${DEVICE_SCANOUT_MAX_RENDER:-400}
    # The pipe fetches lines in panel orientation, so on a rotated output a line is the frame height
    if [ -n "${DEVICE_SCANOUT_MAX_FETCH}" ]; then
      case ${OUTPUT_TRANSFORM} in
        90|270|flipped-90|flipped-270) SCALING_FETCH=${SCALING_H} ;;
        *)                             SCALING_FETCH=${SCALING_W} ;;
      esac
      SCALING_FETCH=$(( DEVICE_SCANOUT_MAX_FETCH * 100 / SCALING_FETCH ))
      [ "${SCALING_FETCH}" -lt "${SCALING_MAX}" ] && SCALING_MAX=${SCALING_FETCH}
    fi
    SCALING_MAX_H=$(( SCALING_H * SCALING_MAX / 100 ))
    export SCANOUT_RENDER=${SCALING_RENDER} SCANOUT_OWNER=$$ SCANOUT_MAX_RENDER=${SCALING_MAX} \
           SCANOUT_OUTPUT=${OUTPUT_NAME}
    [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ] && export SCANOUT_OUTPUT2=${OUTPUT2_NAME}
    SCALING_MULT=""
    case ${SCALING_RENDER} in
      internal) SCALING_MULT=100; [ -z "${NATIVE_H}" ] && SCALING_RENDER=100 ;;
      [0-9]*x)
        SCALING_MULT=$(awk -v n="${SCALING_RENDER%x}" 'BEGIN { if (n + 0 > 0) printf "%d", n * 100 }')
        if [ -z "${SCALING_MULT}" ] || [ -z "${NATIVE_H}" ]; then SCALING_MULT=""; SCALING_RENDER=100; fi ;;
      *[!0-9]*) SCALING_RENDER=59 ;;
    esac
    if [ -n "${SCALING_MULT}" ] && [ -n "${NATIVE_H}" ]; then

      SCALING_RENDER_H=$(( (NATIVE_H * SCALING_MULT / 100) / 2 * 2 ))
      if [ "${SCALING_RENDER_H}" -gt "${SCALING_MAX_H}" ]; then
        SCALING_MULT=$(( SCALING_MAX_H * 100 / NATIVE_H / 100 * 100 ))
        [ "${SCALING_MULT}" -lt 100 ] && SCALING_MULT=100
        SCALING_RENDER_H=$(( (NATIVE_H * SCALING_MULT / 100) / 2 * 2 ))
      fi
      SCALING_RENDER_W=$(( (SCALING_RENDER_H * SCALING_W / SCALING_H) / 2 * 2 ))
      SCALING_RENDER="native ${SCALING_MULT}%"
    else
      [ "${SCALING_RENDER}" -lt 25 ] && SCALING_RENDER=25
      [ "${SCALING_RENDER}" -gt "${SCALING_MAX}" ] && SCALING_RENDER=${SCALING_MAX}
      SCALING_RENDER_W=$(( (SCALING_W * SCALING_RENDER / 100) / 2 * 2 ))
      SCALING_RENDER_H=$(( (SCALING_H * SCALING_RENDER / 100) / 2 * 2 ))
      # Nearest only looks right at a whole factor, so snap to the closest one
      if [ "${SCALING_FILTER}" = "hardware_nearest" ]; then
        if [ "${SCALING_RENDER}" -lt 100 ]; then
          SCALING_INT=$(( (100 + SCALING_RENDER / 2) / SCALING_RENDER ))
          [ "${SCALING_INT}" -lt 2 ] && SCALING_INT=2
          SCALING_RENDER_W=$(( (SCALING_W / SCALING_INT) / 2 * 2 ))
          SCALING_RENDER_H=$(( (SCALING_H / SCALING_INT) / 2 * 2 ))
        elif [ "${SCALING_RENDER}" -gt 100 ]; then
          SCALING_INT=$(( (SCALING_RENDER + 50) / 100 ))
          [ "${SCALING_INT}" -lt 2 ] && SCALING_INT=2
          [ "${SCALING_INT}" -gt 4 ] && SCALING_INT=4
          [ "${SCALING_INT}" -gt $(( SCALING_MAX / 100 )) ] && SCALING_INT=$(( SCALING_MAX / 100 ))
          SCALING_RENDER_W=$(( SCALING_W * SCALING_INT ))
          SCALING_RENDER_H=$(( SCALING_H * SCALING_INT ))
        fi
      fi
      SCALING_RENDER="${SCALING_RENDER}% of screen"
    fi

    # Frames taller than the plane can rotate are pre-rotated, so the plane only scales them
    if [ -n "${DEVICE_PLANE_ROTATION_MAX_HEIGHT}" ] && [ "${SCALING_RENDER_H}" -gt "${DEVICE_PLANE_ROTATION_MAX_HEIGHT}" ]; then
      case ${OUTPUT_TRANSFORM} in
        90|270)
          prerotate_env "${OUTPUT_TRANSFORM}" always
          ${VERBOSE} && log $0 "Pre-rotation ${vk_wsi_wayland_prerotate} (${SCALING_RENDER_H} lines is over the plane's ${DEVICE_PLANE_ROTATION_MAX_HEIGHT})"
        ;;
      esac
    fi

    # SDL sizes HiDPI windows from the fractional scale.
    export GDK_SCALE=1.0001
    [ -n "${OUTPUT_NAME}" ] && scanout_set_render "${OUTPUT_NAME}" "${SCALING_H}" "${SCALING_RENDER_H}"
    ${VERBOSE} && log $0 "Scaling ${SCALING_RENDER} (${SCALING_RENDER_W}x${SCALING_RENDER_H} -> ${SCALING_W}x${SCALING_H}, filter ${SCALING_FILTER})"
  fi
else
  prerotate_env
fi

# If the rom is a shell script just execute it, useful for DOSBOX and ScummVM scan scripts
if [[ "${ROMNAME}" == *".sh" ]] && [ ! "${PLATFORM}" = "ports" ] && [ ! "${PLATFORM}" = "windows" ]; then
        ${VERBOSE} && log $0 "Executing shell script ${ROMNAME}"
        ${GAMESCOPE_CMD} "${ROMNAME}" &>>${OUTPUT_LOG}
        ret_error=$?
else
        ${VERBOSE} && log $0 "Executing $(eval echo ${RUNTHIS})"
        eval ${RUNTHIS} &>>${OUTPUT_LOG}
        ret_error=$?
fi

### Switch back to performance mode to clean up
performance

clear_screen

### Reset this game's scan out scaling and sharpening
if [ -f "${SCANOUT_OWNER_FILE}" ]; then
  scanout_reset
  trap - EXIT
fi

### Disable touch on the secondary screen for dual screen devices
if [[ "${DEVICE_HAS_DUAL_SCREEN}" == "true" ]]; then
  # Disable touch events for Retroid Pocket devices to prevent focus loss
  if [[ "${QUIRK_DEVICE}" == "Retroid Pocket 5" || "${QUIRK_DEVICE}" == "Retroid Pocket Flip2" || "${QUIRK_DEVICE}" == "Retroid Pocket Mini" || "${QUIRK_DEVICE}" == "Retroid Pocket Mini V2" ]]; then
    swaymsg input "0:0:generic_ft5x06_(a0)" events disabled
    swaymsg input "0:0:generic_ft5x06_(8d)" events disabled
  fi
fi

### Go back to system display mode , if we had specialized mode defined
DISPLAY_MODE=$(get_setting "display_mode" "${PLATFORM}" "${ROMNAME##*/}")
if [ ! -z "${DISPLAY_MODE}" ] && [ "${DISPLAY_MODE}" != "default" ]
then
  DISPLAY_MODE=$(get_setting "system.display_mode")
  DISPLAY_OUTPUT=$(/usr/bin/wlr-randr | awk 'NR==1{print $1;}')
  if [ -z "${DISPLAY_MODE}" ]; then
    # if we have no system mode use the displays preferred mode
    /usr/bin/wlr-randr --output ${DISPLAY_OUTPUT} --preferred
  else
    # If we have user specifed system mode set that
    set_refresh_rate "${DISPLAY_MODE}"
  fi
fi

### Restore cooling profile.
if [ "${DEVICE_HAS_FAN}" = "true" ]
then
  ${VERBOSE} && log $0 "Restore system cooling profile (${COOLINGPROFILE})"
  set_setting cooling.profile ${COOLINGPROFILE}
  systemctl restart fancontrol &
fi

### Restore system GPU performance mode
GPUPERF=$(get_setting "system.gpuperf")
if [ ! -z ${GPUPERF} ]
then
  ${VERBOSE} && log $0 "Restore system GPU performance mode (${GPUPERF})"
  gpu_performance_level ${GPUPERF} &
else
  ${VERBOSE} && log $0 "Restore system GPU performance mode (auto)"
  gpu_performance_level auto &
fi
rm -f /tmp/.gpu_performance_level 2>/dev/null

### Reset the number of cores to use.
NUMTHREADS=$(get_setting "system.threads")
${VERBOSE} && log $0 "Restore active threads (${NUMTHREADS})"
if [ -n "${NUMTHREADS}" ]
then
        onlinethreads ${NUMTHREADS} 0 &
else
        onlinethreads all 1 &
fi

### Disable GPU profiling
gpu_profiling "off"

### Backup save games
CLOUD_BACKUP=$(get_setting "cloud.backup")
if [ "${CLOUD_BACKUP}" = "1" ]
then
  INETUP=$(/usr/bin/amionline >/dev/null 2>&1)
  if [ $? == 0 ]
  then
    log $0 "backup saves to the cloud."
    /usr/bin/run /usr/bin/cloud_backup
  fi
fi

${VERBOSE} && log $0 "Checking errors: ${ret_error} "
### Report how the launch ended. EmulationStation records play count, play time
### and last-played only on 0 (FileData::launchGame) and passes the same code to
### whatever runs after the game. The global exit hotkey (input_sense, execute_kill) ends
### a standalone emulator with killall -9 and RetroArch with SIGTERM, so 137 and
### 143 are the player leaving, not a failed launch: a clean exit. Every other
### non-zero status still collapses to 1 -- ES keeps 200-300 for messages it can
### name, and an emulator's own codes would land in that range.
case "${ret_error}" in
  0)
        quit 0
  ;;
  137|143)
        log $0 "emulator ended by signal (${ret_error}, the exit hotkey); a clean exit"
        quit 0
  ;;
  *)
        log $0 "exiting with ${ret_error}"
        quit 1
  ;;
esac
