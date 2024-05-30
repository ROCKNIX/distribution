#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 mupen64plus"

# Emulation Station features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
SCREENWIDTH=$(fbwidth)
SCREENHEIGHT=$(fbheight)
ASPECT=$(get_setting game_aspect_ratio "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
RSP=$(get_setting rsp_plugin "${PLATFORM}" "${GAME}")
SIMPLECORE=$(get_setting core_plugin "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
PAK=$(get_setting controller_pak "${PLATFORM}" "${GAME}")
CON=$(get_setting input_configuration "${PLATFORM}" "${GAME}")
VPLUGIN=$(get_setting video_plugin "${PLATFORM}" "${GAME}")
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")

# File locations
SHARE="/usr/local/share/mupen64plus"
GAMEDATA="/storage/.config/mupen64plus"
M64PCONF="${GAMEDATA}/mupen64plus.cfg"
CUSTOMINP="${GAMEDATA}/custominput.ini"
TMP="/tmp/mupen64plus"

# Clean and create directories
rm -rf ${TMP}
mkdir -p ${TMP}
mkdir -p ${GAMEDATA}

# Copy files to GAMEDATA
if [[ ! -f "${M64PCONF}" ]]; then
    cp ${SHARE}/mupen64plus.cfg* ${M64PCONF}
fi
if [[ ! -f "${CUSTOMINP}" ]]; then
    cp ${SHARE}/default.ini ${CUSTOMINP}
fi

# Copy files to TMP
cp ${M64PCONF} ${TMP}
if [ "${CON}" = "custom" ]; then
    cp ${CUSTOMINP} ${TMP}/InputAutoCfg.ini
elif [ "${CON}" = "standard" ]; then
    cp ${SHARE}/default.ini ${TMP}/InputAutoCfg.ini
else
    cp ${SHARE}/default.ini ${TMP}/InputAutoCfg.ini
fi
if [ $(echo $1 | grep -i .zip | wc -l) -eq 1 ]; then
    # Unzip the game ROM if needed
    unzip -q -o "$1" -d ${TMP}
    ROM=$(unzip -Zl -1 "$1")
else
    cp "$1" ${TMP}
    ROM="${GAME}"
fi

# CPU core settings
if [ "${CORES}" = "little" ]; then
    EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]; then
    EMUPERF="${FAST_CORES}"
else
    unset EMUPERF
fi

# Configure Mupen64Plus-SA parameters
SET_PARAMS=""

# Emulator core settings
SET_PARAMS+=" --set Core[SharedDataPath]=${TMP}"
if [ "${SIMPLECORE}" = "simple" ]; then
    SIMPLESUFFIX="-simple"
    SET_PARAMS+=" --set Core[R4300Emulator]=1"
else
    SIMPLESUFFIX=""
    SET_PARAMS+=" --set Core[R4300Emulator]=2"
fi

# Input settings
SET_PARAMS+=" --set Input-SDL-Control1[plugin]=${PAK}"
SET_PARAMS+=" --set Input-SDL-Control2[plugin]=${PAK}"
SET_PARAMS+=" --set Input-SDL-Control3[plugin]=${PAK}"
SET_PARAMS+=" --set Input-SDL-Control4[plugin]=${PAK}"

# Video settings
SET_PARAMS+=" --set Video-General[ScreenHeight]=${SCREENHEIGHT}"
SET_PARAMS+=" --set Video-Parallel[ScreenWidth]=${SCREENWIDTH}"
SET_PARAMS+=" --set Video-Parallel[ScreenHeight]=${SCREENHEIGHT}"
SET_PARAMS+=" --set Video-Parallel[Upscaling]=${IRES}"
SET_PARAMS+=" --set Video-GLideN64[UseNativeResolutionFactor]=${IRES}"
SET_PARAMS+=" --set Video-Rice[ResolutionWidth]=${SCREENWIDTH}"
if [ "${ASPECT}" = "fullscreen" ]; then
    SET_PARAMS+=" --set Video-General[ScreenWidth]=${SCREENWIDTH}"
    SET_PARAMS+=" --set Video-Parallel[WidescreenStretch]=False"
    SET_PARAMS+=" --set Video-GLideN64[AspectRatio]=3"
    SET_PARAMS+=" --set Video-Glide64mk2[aspect]=2"
else
    if [ -z "${VPLUGIN}" ] || [ "${VPLUGIN}" = "rice" ]; then
        GAMEWIDTH=$(((SCREENHEIGHT * 4) / 3))
        SET_PARAMS+=" --set Video-General[ScreenWidth]=${GAMEWIDTH}"
    else
        SET_PARAMS+=" --set Video-General[ScreenWidth]=${SCREENWIDTH}"
    fi
    SET_PARAMS+=" --set Video-Parallel[WidescreenStretch]=False"
    SET_PARAMS+=" --set Video-GLideN64[AspectRatio]=1"
    SET_PARAMS+=" --set Video-Glide64mk2[aspect]=0"
fi
if [ "${FPS}" = "true" ]; then
    export LIBGL_SHOW_FPS="1"
    export GALLIUM_HUD="cpu+GPU-load+fps"
    SET_PARAMS+=" --set Video-GLideN64[ShowFPS]=True"
    SET_PARAMS+=" --set Video-Glide64mk2[show_fps]=1"
    SET_PARAMS+=" --set Video-Rice[ShowFPS]=True"
else
    export LIBGL_SHOW_FPS="0"
    export GALLIUM_HUD="off"
    SET_PARAMS+=" --set Video-GLideN64[ShowFPS]=False"
    SET_PARAMS+=" --set Video-Glide64mk2[show_fps]=0"
    SET_PARAMS+=" --set Video-Rice[ShowFPS]=False"
fi

# Set the video plugin
case ${VPLUGIN} in
    "rmg_parallel")
        SET_PARAMS+=" --gfx mupen64plus-video-parallel${SIMPLESUFFIX}.so"
        RSP="parallel"
    ;;
    "gliden64")
        SET_PARAMS+=" --gfx mupen64plus-video-GLideN64${SIMPLESUFFIX}.so"
    ;;
    "gl64mk2")
        SET_PARAMS+=" --gfx mupen64plus-video-glide64mk2${SIMPLESUFFIX}.so"
    ;;
    "rice")
        SET_PARAMS+=" --gfx mupen64plus-video-rice${SIMPLESUFFIX}.so"
    ;;
    *)
        SET_PARAMS+=" --gfx mupen64plus-video-rice${SIMPLESUFFIX}.so"
    ;;
esac

# Set the RSP plugin
case "${RSP}" in
    "parallel")
        SET_PARAMS+=" --rsp mupen64plus-rsp-parallel${SIMPLESUFFIX}.so"
    ;;
    "hle")
        SET_PARAMS+=" --rsp mupen64plus-rsp-hle${SIMPLESUFFIX}.so"
    ;;
    *)
        SET_PARAMS+=" --rsp mupen64plus-rsp-cxd4${SIMPLESUFFIX}.so"
    ;;
esac

# Set the remaining plugins
SET_PARAMS+=" --input mupen64plus-input-sdl${SIMPLESUFFIX}.so"
SET_PARAMS+=" --audio mupen64plus-audio-sdl${SIMPLESUFFIX}.so"

# Echo the command line options to the log for debugging
echo ${SET_PARAMS}

${EMUPERF} /usr/local/bin/mupen64plus${SIMPLESUFFIX} --configdir ${TMP} ${SET_PARAMS} "${TMP}/${ROM}"
