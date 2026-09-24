#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 mupen64plus mupen64plus-sim"

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
GLIDEN64CONF=$(get_setting gliden64_profiles "${PLATFORM}" "${GAME}")

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
    cp ${SHARE}/mupen64plus.cfg* ${GAMEDATA}
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

# AMD64: player 1's layout and Select + button hotkeys from its ES mapping
if [ "${HW_DEVICE}" = "AMD64" ] && [ "${CON}" != "custom" ] && mkcontroller; then
    . /storage/.config/profile.d/098-controller
    control-gen_init.sh
    source /storage/.config/gptokeyb/control.ini
    get_controls
    m64() {
        case "$1" in
            "") ;;
            h*) local d="${1:2}"; echo "hat(${1:1:1} ${d^})" ;;
            *[+-]) echo "axis(${1}${2:+,$2})" ;;
            *) echo "button($1)" ;;
        esac
    }
    cat <<EOF >>${TMP}/InputAutoCfg.ini

[${param_device}]
plugged = True
mouse = False
AnalogDeadzone = 4096,4096
AnalogPeak = 32768,32768
DPad R = $(m64 ${DEVICE_BTN_DPAD_RIGHT})
DPad L = $(m64 ${DEVICE_BTN_DPAD_LEFT})
DPad D = $(m64 ${DEVICE_BTN_DPAD_DOWN})
DPad U = $(m64 ${DEVICE_BTN_DPAD_UP})
Start = $(m64 ${DEVICE_BTN_START})
Z Trig = $(m64 ${DEVICE_BTN_TL2})
B Button = $(m64 ${DEVICE_BTN_WEST})
A Button = $(m64 ${DEVICE_BTN_SOUTH})
C Button R = $(m64 ${DEVICE_BTN_AR_RIGHT} 24000)
C Button L = $(m64 ${DEVICE_BTN_AR_LEFT} 24000) $(m64 ${DEVICE_BTN_NORTH})
C Button D = $(m64 ${DEVICE_BTN_AR_DOWN} 24000) $(m64 ${DEVICE_BTN_EAST})
C Button U = $(m64 ${DEVICE_BTN_AR_UP} 24000)
R Trig = $(m64 ${DEVICE_BTN_TR2}) $(m64 ${DEVICE_BTN_TR})
L Trig = $(m64 ${DEVICE_BTN_TL})
X Axis = axis(${DEVICE_BTN_AL_LEFT%?}-,${DEVICE_BTN_AL_RIGHT%?}+)
Y Axis = axis(${DEVICE_BTN_AL_UP%?}-,${DEVICE_BTN_AL_DOWN%?}+)
EOF
    j() { case "$1" in *[+-]) echo "A$1" ;; *) echo "B$1" ;; esac; }
    HK="J0B${DEVICE_BTN_SELECT}"
    SLOT=""
    [[ "${DEVICE_BTN_DPAD_UP}" =~ ^[0-9]+$ ]] && SLOT="${HK}/B${DEVICE_BTN_DPAD_UP}"
    sed -i -e "s|^Joy Mapping Stop = .*|Joy Mapping Stop = \"${HK}/$(j ${DEVICE_BTN_START})\"|" \
           -e "s|^Joy Mapping Save State = .*|Joy Mapping Save State = \"${HK}/$(j ${DEVICE_BTN_TR})\"|" \
           -e "s|^Joy Mapping Load State = .*|Joy Mapping Load State = \"${HK}/$(j ${DEVICE_BTN_TL})\"|" \
           -e "s|^Joy Mapping Fast Forward = .*|Joy Mapping Fast Forward = \"${HK}/$(j ${DEVICE_BTN_TR2})\"|" \
           -e "s|^Joy Mapping Pause = .*|Joy Mapping Pause = \"${HK}/$(j ${DEVICE_BTN_NORTH})\"|" \
           -e "s|^Joy Mapping Increment Slot = .*|Joy Mapping Increment Slot = \"${SLOT}\"|" \
           -e "s#^Joy Mapping \(Reset\|Screenshot\|Gameshark\) = .*#Joy Mapping \1 = \"\"#" ${TMP}/mupen64plus.cfg
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

# GLideN64 Profiles
if [ "${GLIDEN64CONF}" = "performance" ]; then
	SET_PARAMS+=" --set Video-GLideN64[EnableLOD]=False"
	SET_PARAMS+=" --set Video-GLideN64[EnableLegacyBlending]=True"
	SET_PARAMS+=" --set Video-GLideN64[EnableHybridFilter]=False"
	SET_PARAMS+=" --set Video-GLideN64[EnableInaccurateTextureCoordinates]=True"
	SET_PARAMS+=" --set Video-GLideN64[EnableCopyColorToRDRAM]=0"
	SET_PARAMS+=" --set Video-GLideN64[EnableCopyDepthToRDRAM]=0"
	SET_PARAMS+=" --set Video-GLideN64[BackgroundsMode]=0"
	SET_PARAMS+=" --set Video-GLideN64[RDRAMImageDitheringMode]=0"
	SET_PARAMS+=" --set Video-GLideN64[CorrectTexrectCoords]=0"
else
	SET_PARAMS+=" --set Video-GLideN64[EnableLOD]=True"
	SET_PARAMS+=" --set Video-GLideN64[EnableLegacyBlending]=False"
	SET_PARAMS+=" --set Video-GLideN64[EnableHybridFilter]=False"
	SET_PARAMS+=" --set Video-GLideN64[EnableInaccurateTextureCoordinates]=False"
	SET_PARAMS+=" --set Video-GLideN64[EnableCopyColorToRDRAM]=2"
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
