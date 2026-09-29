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
### The platform is the first -P<platform> argument after the ROM, taken
### whole. ${ARGUMENTS##*-P} read from the LAST "-P" anywhere in the joined
### line, so a netplay nick such as My-Player made the platform "layer"
### (#308, stream E2's reading of the launch command).
PLATFORM=""
for ARG in "${@:2}"; do case "${ARG}" in -P?*) PLATFORM="${ARG#-P}"; break ;; esac; done
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

### The marker the global exit hotkey leaves behind (input_sense,
### execute_kill): cleared before the emulator starts, consumed by the exit
### mapping at the bottom of this script -- fork #92, D-LAUNCH-002. It sits
### in /tmp beside the kill data the same hotkey reads
### (/tmp/.process-kill-data) because /tmp is a tmpfs: a power cut wipes it,
### which is exactly what is wanted of a flag that must never outlive the
### boot. input.service and this script both run as root, so each can write
### and remove the other's marker.
EXIT_HOTKEY_MARKER="/tmp/.process-kill-requested"

### Export Game Guide Path
GAME_GUIDE_PATH_CHECK="${1%.*}.txt"
if [ ! -f "${GAME_GUIDE_PATH_CHECK}" ]; then
  GAME_GUIDE_PATH_CHECK="No Game Guide Found"
fi
  /usr/bin/game-guides-tool "${1}"

### Function Library
### Every line this script logs -- to exec.log or to its own stdout, which
### the journal keeps -- goes through redact_credentials (001-functions): a
### credential's value reads <redacted>, its key or flag stays. The
### "Executing ..." line carries an emulator's whole command line, and a
### standalone emulator can take a password there (gopher64's --ra-password);
### exec.log is what rocknix-evidence bundles (fork #176, D-INFRA-010). The
### emulator's own output is still redirected straight into the file below,
### not piped through a filter: a game's life must not depend on a second
### process staying alive to read its stdout. The bundle is filtered whole.
function log() {
        if [ ${LOG} == true ]
        then
                if [[ ! -d "$LOG_DIRECTORY" ]]
                then
                        mkdir -p "$LOG_DIRECTORY"
                fi
                redact_credentials "${SCRIPT_NAME}: $*" 2>&1 | tee -a ${LOG_DIRECTORY}/${LOG_FILE}
        else
                redact_credentials "${SCRIPT_NAME}: $*"
        fi
}

function loginit() {
        # The launch log is one launch's, whatever the log level (fork #280).
        # The emulator's output is appended to it below whether or not this
        # script logs, and it used to be truncated only when the level was not
        # none -- so on a device with system.loglevel=none every launch since
        # the file was last removed sat in it, the interface read a rotated
        # game's SET_ROTATION line as the next game's, and rocknix-evidence
        # bundled weeks of launches as one. Truncate first, then the header.
        rm -f ${LOG_DIRECTORY}/${LOG_FILE}
        if [ ${LOG} == true ]
        then
                redact_credentials <<EOF >${LOG_DIRECTORY}/${LOG_FILE}
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
                : >${LOG_DIRECTORY}/${LOG_FILE}
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
### The save state manager's arguments follow --controllers= on the command
### line. The interface writes them, this script reads them, setsettings.sh
### turns them into RetroArch's configuration (fork #196, D-UI-057):
###   -autosave 0|1       the exit auto save and auto-load, off or on, for this run
###   -state_slot N       RetroArch's current slot (-1 is its auto slot)
###   -state_file <path>  the state to start from: the .auto file, or a slot's
### Since es_savestates.cfg each of them can arrive on its own -- "-autosave 1
### -state_file <auto>" for the AUTO SAVE tile and for a plain launch with AUTO
### SAVE/LOAD on, "-autosave 0" alone for START NEW GAME, "-state_slot N
### -state_file <slot file>" for a numbered slot -- where the interface's
### built-in fallback always sent -state_slot with them. Sets CONTROLLERCONFIG,
### SNAPSHOT, AUTOSAVE and STATEFILE; call it with the script's own "$@".
function parse_savestate_arguments() {
  CONTROLLERCONFIG="${ARGUMENTS#*--controllers=*}"
  SNAPSHOT=""
  AUTOSAVE=""
  STATEFILE=""

  ### Each value is the argument after its flag, from the argument list --
  ### the shell already split it. The state file is a path, and ROM names
  ### carry spaces, parentheses and " - " (Mario Tennis - Power Tour (USA,
  ### Australia)), so it was always taken this way; the slot and the auto
  ### save were cut out of the joined line, where the FIRST " -state_slot "
  ### could be inside the ROM's own name ("Demo -state_slot 2 - Part.sfc")
  ### and win over the real flag (#308, the gpt seat's F-PB-17).
  local PREVIOUS="" ARGUMENT FLAGGED=0
  for ARGUMENT in "$@"
  do
    case "${PREVIOUS}" in
      -state_slot) SNAPSHOT="${ARGUMENT}" ;;
      -autosave)   AUTOSAVE="${ARGUMENT}" ;;
      -state_file) STATEFILE="${ARGUMENT}" ;;
    esac
    case "${ARGUMENT}" in
      -state_slot|-autosave|-state_file) FLAGGED=1 ;;
    esac
    PREVIOUS="${ARGUMENT}"
  done

  if [ "${FLAGGED}" -eq 1 ]
  then
    ### The controllers value ends where the first of them begins.
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% -state_slot *}"
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% -autosave *}"
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% -state_file *}"
  else
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% --*}"  # until a -- is found
  fi
}

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

    parse_savestate_arguments "$@"

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
    ### --state_file= goes ahead of --controllers=: setsettings reads CONTROLLERS
    ### as everything after --controllers=, and a state file's path is a ROM
    ### name, which can hold "p1" and would read as a controller (#196).
    ${VERBOSE} && log $0 "Execute setsettings (${PLATFORM} ${ROMNAME} ${CORE} --state_file=${STATEFILE} --controllers=${CONTROLLERCONFIG} --autosave=${AUTOSAVE} --snapshot=${SNAPSHOT})"
    (/usr/bin/setsettings.sh "${PLATFORM}" "${ROMNAME}" "${CORE}" --state_file="${STATEFILE}" --controllers="${CONTROLLERCONFIG}" --autosave="${AUTOSAVE}" --snapshot="${SNAPSHOT}" >${SET_SETTINGS_TMP})

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

### Clear the exit hotkey marker on the way into the emulator, so a press
### left over from an earlier launch -- or from the carousel, where the same
### hotkey kills EmulationStation -- can never be read as this launch ending
### (fork #92). Both dispatch paths below run through here, and nothing above
### it starts an emulator; keep it that way.
rm -f "${EXIT_HOTKEY_MARKER}"

# If the rom is a shell script just execute it, useful for DOSBOX and ScummVM scan scripts
if [[ "${ROMNAME}" == *".sh" ]] && [ ! "${PLATFORM}" = "ports" ] && [ ! "${PLATFORM}" = "windows" ]; then
        ${VERBOSE} && log $0 "Executing shell script ${ROMNAME}"
        "${ROMNAME}" &>>${OUTPUT_LOG}
        ret_error=$?
else
        ${VERBOSE} && log $0 "Executing $(eval echo ${RUNTHIS})"
        eval ${RUNTHIS} &>>${OUTPUT_LOG}
        ret_error=$?
fi

### Switch back to performance mode to clean up
performance

clear_screen

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

### Capture and the game-exit save sync run from EmulationStation (FileData::launchGame, fork #21).
### Never spawn a second uploader here: it would run before ES resumes, so before capture, as a second writer on one remote (#21 DOES-NOT-BUILD).

${VERBOSE} && log $0 "Checking errors: ${ret_error} "
### Report how the launch ended. EmulationStation records play count, play time
### and last-played only on 0 (FileData::launchGame) and hands the same code to
### cloud_capture --exit. The global exit hotkey (input_sense, execute_kill) ends
### a standalone emulator with killall -9 and RetroArch with SIGTERM, so 137 and
### 143 are the player leaving, not a failed launch: a clean exit. Every other
### non-zero status still collapses to 1 -- ES keeps 200-300 for messages it can
### name, and an emulator's own codes would land in that range.
###
### 137/143 cover an emulator that dies on the signal. RetroArch does not: it
### catches SIGTERM and ends with its own exit(1), which is the same status as
### "Failed to load content", so no rule reading the code alone can tell a
### forced quit from a failed launch. The hotkey therefore says so itself --
### execute_kill touches ${EXIT_HOTKEY_MARKER} immediately before the killall,
### and a non-zero status that follows a press is read as the player leaving
### (fork #92, D-LAUNCH-002). A launch with no marker behaves exactly as before.
### Consume the marker here whatever happened, so it cannot reach another launch.
EXIT_HOTKEY_PRESSED=false
if [ -e "${EXIT_HOTKEY_MARKER}" ]
then
        EXIT_HOTKEY_PRESSED=true
        rm -f "${EXIT_HOTKEY_MARKER}"
fi
case "${ret_error}" in
  0)
        quit 0
  ;;
  137|143)
        log $0 "emulator ended by signal (${ret_error}, the exit hotkey); a clean exit"
        quit 0
  ;;
  *)
        if [ "${EXIT_HOTKEY_PRESSED}" = true ]
        then
                log $0 "emulator exited ${ret_error} after the exit hotkey was pressed (marker consumed); a clean exit"
                quit 0
        fi
        log $0 "exiting with ${ret_error}"
        quit 1
  ;;
esac
