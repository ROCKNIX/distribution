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
BLUETOOTH_STATE=$(get_setting bluetooth.enabled)
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
      "gamecube")
        RUNTHIS='${RUN_SHELL} /usr/bin/start_dolphin_gc.sh "${ROMNAME}"'
      ;;
      "wii")
        RUNTHIS='${RUN_SHELL} /usr/bin/start_dolphin_wii.sh "${ROMNAME}"'
      ;;
      "ports")
        RUNTHIS='${RUN_SHELL} "${ROMNAME}"'
	sed -i "/^ACTIVE_GAME=/c\ACTIVE_GAME=\"${ROMNAME}\"" /storage/.config/PortMaster/mapper.txt
      ;;
      "shell")
        RUNTHIS='${RUN_SHELL} "${ROMNAME}"'
      ;;
      *)
        RUNTHIS='${RUN_SHELL} "start_${CORE%-*}.sh" "${ROMNAME}"'
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

### Set CPU TDP and EPP
CPU_VENDOR=$(cpu_vendor)
case ${CPU_VENDOR} in
  AuthenticAMD)
    ### Set the overclock mode
    OVERCLOCK=$(get_setting "overclock" "${PLATFORM}" "${ROMNAME##*/}")
    if [ ! -z "${OVERCLOCK}" ]
    then
      ${VERBOSE} && log $0 "Set TDP to (${OVERCLOCK})"
      /usr/bin/overclock ${OVERCLOCK}
    fi
  ;;
esac

### Apply energy performance preference
if [ -e "/usr/bin/set_epp" ]
then
  EPP=$(get_setting "power.epp" "${PLATFORM}" "${ROMNAME##*/}")
  if [ ! -z ${EPP} ]
  then
    ${VERBOSE} && log $0 "Set EPP to (${EPP})"
    /usr/bin/set_epp ${EPP}
  fi
fi

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
if [ ! -z "${DISPLAY_MODE}" ]
then
DISPLAY_OUTPUT=$(/usr/bin/wlr-randr | awk 'NR==1{print $1;}')
RESOLUTION=$(/usr/bin/wlr-randr --output ${DISPLAY_OUTPUT} | awk 'f{print $1;f=0}/Modes/{f=1}')
/usr/bin/wlr-randr --output ${DISPLAY_OUTPUT} --mode ${RESOLUTION}@$(echo ${DISPLAY_MODE} | tr -cd '[[:digit:]].')
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

# If the rom is a shell script just execute it, useful for DOSBOX and ScummVM scan scripts
if [[ "${ROMNAME}" == *".sh" ]]; then
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

### Display mode preferred
DISPLAY_MODE=$(get_setting "display_mode" "${PLATFORM}" "${ROMNAME##*/}")
if [ ! -z "${DISPLAY_MODE}" ]
then
DISPLAY_OUTPUT=$(/usr/bin/wlr-randr | awk 'NR==1{print $1;}')
/usr/bin/wlr-randr --output ${DISPLAY_OUTPUT} --preferred
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

### Restore system EPP
EPP=$(get_setting "system.power.epp")
if [ ! -z ${EPP} ]
then
  ${VERBOSE} && log $0 "Restore system EPP (${EPP})"
  /usr/bin/set_epp ${EPP} &
fi

### Restore system TDP
OVERCLOCK=$(get_setting "system.overclock")
if [ ! -z "${OVERCLOCK}" ]
then
  ${VERBOSE} && log $0 "Restore system TDP (${OVERCLOCK})"
  /usr/bin/overclock ${OVERCLOCK} &
fi

### Reset the number of cores to use.
NUMTHREADS=$(get_setting "system.threads")
${VERBOSE} && log $0 "Restore active threads (${NUMTHREADS})"
if [ -n "${NUMTHREADS}" ]
then
        onlinethreads ${NUMTHREADS} 0 &
else
        onlinethreads all 1 &
fi

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
if [ "${ret_error}" == "0" ]
then
        quit 0
else
        log $0 "exiting with ${ret_error}"
        quit 1
fi
