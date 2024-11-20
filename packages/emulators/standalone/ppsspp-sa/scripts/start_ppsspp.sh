#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

SOURCE_DIR="/usr/config/ppsspp"
CONF_DIR="/storage/.config/ppsspp"
PPSSPP_INI="/PSP/SYSTEM/ppsspp.ini"

if [ ! -d "${CONF_DIR}" ]
then
  cp -rf ${SOURCE_DIR} ${CONF_DIR}
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
FSKIP=$(get_setting frame_skip "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
SKIPB=$(get_setting skip_buffer_effects "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  ### All..
  unset EMUPERF
fi

  #Frame Skip
        if [ "${FSKIP}" = "0" ]
        then
                sed -i '/^FrameSkip =/c\FrameSkip = 0' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^FrameSkipType =/c\FrameSkipType = 0' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^AutoFrameSkip =/c\AutoFrameSkip = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${FSKIP}" = "1" ]
        then
                sed -i '/^FrameSkip =/c\FrameSkip = 1' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^FrameSkipType =/c\FrameSkipType = 0' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^AutoFrameSkip =/c\AutoFrameSkip = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${FSKIP}" = "2" ]
        then
                sed -i '/^FrameSkip =/c\FrameSkip = 2' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^FrameSkipType =/c\FrameSkipType = 0' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^AutoFrameSkip =/c\AutoFrameSkip = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${FSKIP}" = "3" ]
        then
                sed -i '/^FrameSkip =/c\FrameSkip = 3' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^FrameSkipType =/c\FrameSkipType = 0' ${CONF_DIR}/${PPSSPP_INI}
                sed -i '/^AutoFrameSkip =/c\AutoFrameSkip = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${FSKIP}" = "auto" ]
        then
                sed -i '/AutoFrameSkip =/c\AutoFrameSkip = True' ${CONF_DIR}/${PPSSPP_INI}
        fi


  #Graphics Backend
        #Default to OpenGL / GLES if no option is set.
        sed -i '/^GraphicsBackend =/c\GraphicsBackend = 0 (OPENGL)' ${CONF_DIR}/${PPSSPP_INI}

        if [ "${GRENDERER}" = "opengl" ]
        then
                sed -i '/^GraphicsBackend =/c\GraphicsBackend = 0 (OPENGL)' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${GRENDERER}" = "vulkan" ]
        then
                sed -i '/^GraphicsBackend =/c\GraphicsBackend = 3 (VULKAN)' ${CONF_DIR}/${PPSSPP_INI}
        fi

  #Internal Resolution
        if [ "${IRES}" = "1" ]
        then
                sed -i '/^InternalResolution/c\InternalResolution = 1' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${IRES}" = "2" ]
        then
                sed -i '/^InternalResolution/c\InternalResolution = 2' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${IRES}" = "3" ]
        then
                sed -i '/^InternalResolution/c\InternalResolution = 3' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${IRES}" = "4" ]
        then
                sed -i '/^InternalResolution/c\InternalResolution = 4' ${CONF_DIR}/${PPSSPP_INI}
        fi

  #Show FPS
	if [ "${FPS}" = "0" ]
	then
  		sed -i '/^iShowStatusFlags =/c\iShowStatusFlags = 0' ${CONF_DIR}/${PPSSPP_INI}
	fi
	if [ "${FPS}" = "1" ]
	then
  		sed -i '/^iShowStatusFlags =/c\iShowStatusFlags = 2' ${CONF_DIR}/${PPSSPP_INI}
	fi

  #Skip Buffer Effects
        if [ "${SKIPB}" = "0" ]
        then
                sed -i '/^SkipBufferEffects =/c\SkipBufferEffects = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${SKIPB}" = "1" ]
        then
                sed -i '/^SkipBufferEffects =/c\SkipBufferEffects = True' ${CONF_DIR}/${PPSSPP_INI}
        fi

  #VSYNC
        if [ "${VSYNC}" = "0" ]
        then
                sed -i '/^VSyncInterval =/c\VSyncInterval = False' ${CONF_DIR}/${PPSSPP_INI}
        fi
        if [ "${VSYNC}" = "1" ]
        then
                sed -i '/^VSyncInterval =/c\VSyncInterval = True' ${CONF_DIR}/${PPSSPP_INI}
        fi

#Retroachievements
/usr/bin/cheevos_ppsspp.sh

ARG=${1//[\\]/}

set_kill set "-9 ppsspp"

${EMUPERF} ppsspp --pause-menu-exit "${ARG}"
