#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 flycast"

# Conf files vars
SOURCE_DIR="/usr/config/flycast"
CONF_DIR="/storage/.config/flycast"
FLYCAST_INI="emu.cfg"

#Check if flycast exists in .config
if [ ! -d "/storage/.config/flycast" ]; then
        cp -r "${SOURCE_DIR}" "${CONF_DIR}"
fi

#Move save file storage/roms
if [ -d "${CONF_DIR}/data" ]; then
        mv "${CONF_DIR}/data" "/storage/roms/dreamcast/"
fi

#Make flycast bios folder
if [ ! -d "/storage/roms/bios/dc" ]; then
    mkdir -p "/storage/roms/bios/dc"
fi

#Link  .config/flycast to .local
ln -sf "/storage/roms/bios/dc" "/storage/roms/dreamcast/data"

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
ASKIP=$(get_setting auto_frame_skip "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
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

  #AspectRatio
        if [ "$ASPECT" = "w" ]; then
                sed -i '/^rend.WideScreen =/c\rend.WideScreen = yes' "${CONF_DIR}/${FLYCAST_INI}"
                sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = no' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$ASPECT" = "sw" ]; then
                sed -i '/^rend.WideScreen =/c\rend.WideScreen = yes' "${CONF_DIR}/${FLYCAST_INI}"
                sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = yes' "${CONF_DIR}/${FLYCAST_INI}"
	else
		sed -i '/^rend.WideScreen =/c\rend.WideScreen = no' "${CONF_DIR}/${FLYCAST_INI}"
		sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = no' "${CONF_DIR}/${FLYCAST_INI}"
        fi

  #AutoFrameSkip
        if [ "$ASKIP" = "normal" ]; then
                sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 1' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$ASKIP" = "max" ]; then
                sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 2' "${CONF_DIR}/${FLYCAST_INI}"
	else
		sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 0' "${CONF_DIR}/${FLYCAST_INI}"
        fi

  #Internal Resolution
        if [ "$IRES" = "0" ]; then
                sed -i '/rend.Resolution =/c\rend.Resolution = 240' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$IRES" = "2" ]; then
                sed -i '/rend.Resolution =/c\rend.Resolution = 720' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$IRES" = "3" ]; then
                sed -i '/rend.Resolution =/c\rend.Resolution = 960' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$IRES" = "4" ]; then
                sed -i '/rend.Resolution =/c\rend.Resolution = 1200' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$IRES" = "5" ]; then
                sed -i '/rend.Resolution =/c\rend.Resolution = 1440' "${CONF_DIR}/${FLYCAST_INI}"
        else
                sed -i '/rend.Resolution =/c\rend.Resolution = 480' "${CONF_DIR}/${FLYCAST_INI}"
        fi

  #Graphics Renderer
        if [ "$GRENDERER" = "opengl" ]; then
                sed -i '/^pvr.rend =/c\pvr.rend = 0' "${CONF_DIR}/${FLYCAST_INI}"
        elif [ "$GRENDERER" = "vulkan" ]; then
                sed -i '/^pvr.rend =/c\pvr.rend = 4' "${CONF_DIR}/${FLYCAST_INI}"
        else
		sed -i '/^pvr.rend =/c\pvr.rend = @GRENDERER@' "${CONF_DIR}/${FLYCAST_INI}"
	fi

  #ShowFPS
        if [ "$FPS" = "1" ]; then
                sed -i '/^rend.ShowFPS =/c\rend.ShowFPS = yes' "${CONF_DIR}/${FLYCAST_INI}"
	else
		sed -i '/^rend.ShowFPS =/c\rend.ShowFPS = no' "${CONF_DIR}/${FLYCAST_INI}"
        fi

  #Vsync
        if [ "$VSYNC" = "1" ];then
                sed -i '/^rend.vsync =/c\rend.vsync = yes' "${CONF_DIR}/${FLYCAST_INI}"
	else
		sed -i '/^rend.vsync =/c\rend.vsync = no' "${CONF_DIR}/${FLYCAST_INI}"
        fi

#Retroachievements
/usr/bin/cheevos_flycast.sh

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CONF DIR: ${CONF_DIR}/${FLYCAST_INI}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "ASPECT RATIO set to: ${ASPECT}"
  echo "AUTO FRAME SKIP set to: ${ASKIP}"
  echo "INTERNAL RESOLUTION set to: ${IRES}"
  echo "GRAPHICS RENDERER set to: ${GRENDERER}"
  echo "FPS set to: ${FPS}"
  echo "VSYNC set to: ${VSYNC}"
  echo "Launching /usr/bin/flycast ${1}"

#Run flycast emulator
${EMUPERF} /usr/bin/flycast "${1}"
