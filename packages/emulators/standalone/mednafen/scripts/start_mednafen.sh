#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

set -x
set_kill set "-9 mednafen"

export MEDNAFEN_HOME=/storage/.config/mednafen
export MEDNAFEN_CONFIG=/usr/config/mednafen/mednafen.template

if [ ! -d "$MEDNAFEN_HOME" ]
then
  mkdir /storage/.config/mednafen
fi

if [ ! -f "$MEDNAFEN_HOME/mednafen.cfg" ]
then
    /usr/bin/bash /usr/bin/mednafen_gen_config.sh
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
CORE=$(echo "${2}"| sed "s#^/.*/##")
PLATFORM=$(echo "${3}"| sed "s#^/.*/##")
STRETCH=$(get_setting stretch "${PLATFORM}" "${GAME}")
SHADER=$(get_setting shader "${PLATFORM}" "${GAME}")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
FEATURES_CMDLINE=""
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
  if [ "${HW_DEVICE}" = "RK3588" ]; then
    FEATURES_CMDLINE+=" -affinity.emu 0x30 "
    FEATURES_CMDLINE+=" -ss.affinity.vdp2 0xc0 "
  fi
else
  ### All..
  unset EMUPERF
fi

#Set Save paths
sed -i "s/filesys.path_sav .*/filesys.path_sav \/storage\/roms\/${PLATFORM}/g" $MEDNAFEN_HOME/mednafen.cfg
sed -i "s/filesys.path_savbackup.*/filesys.path_savbackup \/storage\/roms\/${PLATFORM}/g" $MEDNAFEN_HOME/mednafen.cfg
sed -i "s/filesys.path_state.*/filesys.path_state \/storage\/roms\/savestates\/${PLATFORM}/g" $MEDNAFEN_HOME/mednafen.cfg

# Get command line switches
CORRECT_ASPECT=$(get_setting correct_aspect ${PLATFORM} "${GAME}")
CR=""
if [ ! -z "${CORRECT_ASPECT}" ] 
then
    CR=" -${CORE}.correct_aspect ${CORRECT_ASPECT}"
fi
if [[ "${CORE}" =~ pce[_fast] ]]
then
    if [ "$(get_setting nospritelimit ${PLATFORM} "${GAME}")" = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.nospritelimit 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.nospritelimit 0"
    fi
    if [ "$(get_setting forcesgx ${PLATFORM} "${GAME}")" = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.forcesgx 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.forcesgx 0"
    fi
    if [ "${CORE}" = pce_fast ]
    then
        FEATURES_CMDLINE+=$CR
        OCM=$(get_setting ocmultiplier ${PLATFORM} "${GAME}")
        if [ ${OCM} > 1 ]
        then
            FEATURES_CMDLINE+=" -${CORE}.ocmultiplier ${OCM}"
        else
            FEATURES_CMDLINE+=" -${CORE}.ocmultiplier 1"
        fi
        CDS=$(get_setting cdspeed ${PLATFORM} "${GAME}")
        if [ ${CDS} > 1 ]
        then
            FEATURES_CMDLINE+=" -${CORE}.cdspeed ${CDS}"
        else
            FEATURES_CMDLINE+=" -${CORE}.cdspeed 1"
        fi
    fi
elif [ "${CORE}" = "gb" ]
then
    ST=$(get_setting system_type "${PLATFORM}" "${GAME}")
    if [[ "${ST}" =~ auto|dmg|cgb|agb  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.system_type ${ST}"
    else
        FEATURES_CMDLINE+=" -${CORE}.system_type auto"
    fi
elif [ "${CORE}" = "gba" ]
then
    if [ $(get_setting tblur "${PLATFORM}" "${GAME}") = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.tblur 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.tblur 0"
    fi
elif [ "${CORE}" = "nes" ]
then
    FEATURES_CMDLINE+=$CR
    if [ $(get_setting clipsides "${PLATFORM}" "${GAME}") = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.clipsides 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.clipsides 0"
    fi
    if [ $(get_setting no8lim "${PLATFORM}" "${GAME}") = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.no8lim 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.no8lim 0"
    fi
elif [ "${CORE}" = "snes_faust" ]
then
    FEATURES_CMDLINE+=$CR
    if [ $(get_setting spex "${PLATFORM}" "${GAME}") = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.spex 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.spex 0"
    fi
    if [ $(get_setting spex.sound "${PLATFORM}" "${GAME}") = "1" ]
    then
        FEATURES_CMDLINE+=" -${CORE}.spex.sound 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.spex.sound 0"
    fi
    SFXCR=$(get_setting superfx.clock_rate ${PLATFORM} "${GAME}")
    if [ ${SFXCR} > 1 ]
    then
        FEATURES_CMDLINE+=" -${CORE}.superfx.clock_rate ${SFXCR}"
    else
        FEATURES_CMDLINE+=" -${CORE}.superfx.clock_rate 100"
    fi
    if [[ "$(get_setting superfx.icache ${PLATFORM} "${GAME}")" == "1" ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.superfx.icache 1"
    else
        FEATURES_CMDLINE+=" -${CORE}.superfx.icache 0"
    fi
    CX4CR=$(get_setting cx4.clock_rate ${PLATFORM} "${GAME}")
    if [ ${CX4CR} > 1 ]
    then
        FEATURES_CMDLINE+=" -${CORE}.cx4.clock_rate ${CX4CR}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cx4.clock_rate 100"
    fi
elif [ "${CORE}" = "vb" ]
then
    CE=$(get_setting cpu_emulation "${PLATFORM}" "${GAME}")
    if [[ "${CE}" =~ fast|accurate  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.cpu_emulation ${CE}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cpu_emulation fast"
    fi
    DM=$(get_setting 3dmode "${PLATFORM}" "${GAME}")
    if [[ "${DM}" =~ anaglyph|cscope|sidebyside|vli|hli|left|right]  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.3dmode ${CE}"
    fi
elif [ "${CORE}" = "pcfx" ]
then
    CE=$(get_setting cpu_emulation "${PLATFORM}" "${GAME}")
    if [[ "${CE}" =~ auto|fast|accurate  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.cpu_emulation ${CE}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cpu_emulation auto"
    fi
    CS=$(get_setting cdspeed "${PLATFORM}" "${GAME}")
    if [ CS > 2]
    then
        FEATURES_CMDLINE+=" -${CORE}.cdspeed ${CS}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cdspeed 2"
    fi
elif [ "${CORE}" = "ss" ]
then
    FEATURES_CMDLINE+=$CR
    IP1=$(get_setting input.port1 "${PLATFORM}" "${GAME}")
    if [[ "${IP1}" =~ gamepad|3dpad|gun  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.input.port1 ${IP1}"
    else
        FEATURES_CMDLINE+=" -${CORE}.input.port1 gamepad"
    fi
    IP13DMODE=$(get_setting input.port1.3dpad.mode.defpos "${PLATFORM}" "${GAME}")
    if [[ "${IP13DMODE}" =~ digital|analog  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.input.port1.3dpad.mode.defpos ${IP13DMODE}"
    else
        FEATURES_CMDLINE+=" -${CORE}.input.port1.3dpad.mode.defpos analog"
    fi
    CART=$(get_setting cart "${PLATFORM}" "${GAME}")
    if [[ "${CART}" =~ auto|none|backup|extram1|extram4|cs1ram16  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.cart ${CART}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cart auto"
    fi
    CARTAD=$(get_setting cart.auto_default "${PLATFORM}" "${GAME}")
    if [[ "${CARTAD}" =~ none|backup|extram1|extram4|cs1ram16  ]]
    then
        FEATURES_CMDLINE+=" -${CORE}.cart.auto_default ${CARTAD}"
    else
        FEATURES_CMDLINE+=" -${CORE}.cart.auto_default none"
    fi
elif [ "${CORE}" = "md" ]
then
    FEATURES_CMDLINE+=$CR
fi

#Run mednafen
@LIBEGL@
${EMUPERF} /usr/bin/mednafen -force_module ${CORE} -${CORE}.stretch ${STRETCH:="aspect"} -${CORE}.shader ${SHADER:="ipsharper"} ${FEATURES_CMDLINE} "${1}"
