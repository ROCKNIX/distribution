#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 duckstation-sa"

# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/duckstation"
CONF_DIR="/storage/.local/share/duckstation"
CONF_FILE="${CONF_DIR}/settings.ini"
SAVESTATES_DIR="/storage/roms/savestates/psx"
MEMCARDS_DIR="/storage/roms/psx/duckstation/memcards"

#Copy config folder to .local/share/duckstation
if [ ! -d "${CONF_DIR}" ]; then
    mkdir -p "${CONF_DIR}"
    cp -r "${IMMUTABLE_CONF_DIR}" "/storage/.local/share/"
fi

if [ ! -f "${CONF_FILE}" ]; then
   cp ${IMMUTABLE_CONF_DIR}/settings.ini ${CONF_FILE}
fi

#Link savestates to roms/savestates
if [ ! -d "${SAVESTATES_DIR}" ]; then
    mkdir -p "${SAVESTATES_DIR}"
fi
if [ -d "${CONF_DIR}/savestates" ]; then
    rm -rf "${CONF_DIR}/savestates"
fi
ln -sfv "${SAVESTATES_DIR}" "${CONF_DIR}/savestates"

# Link memcards to roms
if [ ! -d "${MEMCARDS_DIR}" ]; then
    mkdir -p ${MEMCARDS_DIR}

    # Migrate any existing memcards
    if [ -d "${CONF_DIR}/memcards" ]; then
        cp -rf ${CONF_DIR}/memcards/* ${MEMCARDS_DIR}
    fi
fi
if [ -d "${CONF_DIR}/memcards" ]; then
    rm -rf ${CONF_DIR}/memcards
fi
ln -sfv ${MEMCARDS_DIR} ${CONF_DIR}/memcards

#Link gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt "${CONF_DIR}/gamecontrollerdb.txt"

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
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

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]
	then
  		sed -i '/^AspectRatio/c\AspectRatio = 4:3' ${CONF_FILE}
	fi
        if [ "$ASPECT" = "1" ]
        then
                sed -i '/^AspectRatio/c\AspectRatio = 16:9' ${CONF_FILE}
        fi

  #Show FPS
	if [ "$FPS" = "false" ]
	then
  		sed -i '/^ShowFPS/c\ShowFPS = false' ${CONF_FILE}
	fi
        if [ "$FPS" = "true" ]
        then
                sed -i '/^ShowFPS/c\ShowFPS = true' ${CONF_FILE}
        fi

  #Internal Resolution
        if [ "$IRES" = "1" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 1' ${CONF_FILE}
        fi
        if [ "$IRES" = "2" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 2' ${CONF_FILE}
        fi
        if [ "$IRES" = "3" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 3' ${CONF_FILE}
        fi
        if [ "$IRES" = "4" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 4' ${CONF_FILE}
        fi
        if [ "$IRES" = "5" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 5' ${CONF_FILE}
        fi

  #Video Backend
	if [ "$RENDERER" = "opengl" ]
	then
  		sed -i '/^Renderer =/c\Renderer = OpenGL' ${CONF_FILE}
	fi
        if [ "$RENDERER" = "vulkan" ]
        then
                sed -i '/^Renderer =/c\Renderer = Vulkan' ${CONF_FILE}
        fi
        if [ "$RENDERER" = "software" ]
        then
                sed -i '/^Renderer =/c\Renderer = Software' ${CONF_FILE}
        fi

  #VSYNC
        if [ "$VSYNC" = "off" ]
        then
                sed -i '/^VSync =/c\VSync = false' ${CONF_FILE}
        fi
        if [ "$VSYNC" = "on" ]
        then
                sed -i '/^VSync =/c\VSync = true' ${CONF_FILE}
        fi

#Retroachievements
/usr/bin/cheevos_duckstation.sh

#Run Duckstation
${EMUPERF} duckstation-sa -fullscreen -- "${1}" > /dev/null 2>&1
