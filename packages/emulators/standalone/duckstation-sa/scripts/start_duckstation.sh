#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 duckstation-nogui"

#Copy config folder to .config/duckstation
if [ ! -d "/storage/.config/duckstation" ]; then
    mkdir -p "/storage/.config/duckstation"
    cp -r "/usr/config/duckstation" "/storage/.config/"
fi

if [ ! -d "/storage/.config/duckstation/resources" ]; then
    cp -r /usr/config/duckstation/resources /storage/.config/duckstation/
    rm /storage/.config/duckstation/resources/gamecontrollerdb.txt
    ln -s /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt /storage/.config/duckstation/resources/gamecontrollerdb.txt
fi

if [ ! -f "/storage/.config/duckstation/settings.ini" ]; then
   cp /usr/config/duckstation/settings.ini /storage/.config/duckstation/settings.ini
fi

#Link savestates to roms/savestates
if [ ! -d "/storage/roms/savestates/psx" ]; then
    mkdir -p "/storage/roms/savestates/psx"
fi
if [ -d "/storage/.config/duckstation/savestates" ]; then
    rm -rf "/storage/.config/duckstation/savestates"
fi
ln -sfv "/storage/roms/savestates/psx" "/storage/.config/duckstation/savestates"


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
  		sed -i '/^AspectRatio/c\AspectRatio = 4:3' /storage/.config/duckstation/settings.ini
	fi
        if [ "$ASPECT" = "1" ]
        then
                sed -i '/^AspectRatio/c\AspectRatio = 16:9' /storage/.config/duckstation/settings.ini
        fi

  #Show FPS
	if [ "$FPS" = "false" ]
	then
  		sed -i '/^ShowFPS/c\ShowFPS = false' /storage/.config/duckstation/settings.ini
	fi
        if [ "$FPS" = "true" ]
        then
                sed -i '/^ShowFPS/c\ShowFPS = true' /storage/.config/duckstation/settings.ini
        fi

  #Internal Resolution
        if [ "$IRES" = "1" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 1' /storage/.config/duckstation/settings.ini
        fi
        if [ "$IRES" = "2" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 2' /storage/.config/duckstation/settings.ini
        fi
        if [ "$IRES" = "3" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 3' /storage/.config/duckstation/settings.ini
        fi
        if [ "$IRES" = "4" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 4' /storage/.config/duckstation/settings.ini
        fi
        if [ "$IRES" = "5" ]
        then
                sed -i '/^ResolutionScale =/c\ResolutionScale = 5' /storage/.config/duckstation/settings.ini
        fi

  #Video Backend
	if [ "$RENDERER" = "opengl" ]
	then
  		sed -i '/^Renderer =/c\Renderer = OpenGL' /storage/.config/duckstation/settings.ini
	fi
        if [ "$RENDERER" = "vulkan" ]
        then
                sed -i '/^Renderer =/c\Renderer = Vulkan' /storage/.config/duckstation/settings.ini
        fi
        if [ "$RENDERER" = "software" ]
        then
                sed -i '/^Renderer =/c\Renderer = Software' /storage/.config/duckstation/settings.ini
        fi

  #VSYNC
        if [ "$VSYNC" = "off" ]
        then
                sed -i '/^VSync =/c\VSync = false' /storage/.config/duckstation/settings.ini
        fi
        if [ "$VSYNC" = "on" ]
        then
                sed -i '/^VSync =/c\VSync = true' /storage/.config/duckstation/settings.ini
        fi


#Run Duckstation
${EMUPERF} duckstation-nogui -fullscreen -settings "/storage/.config/duckstation/settings.ini" -- "${1}" > /dev/null 2>&1
