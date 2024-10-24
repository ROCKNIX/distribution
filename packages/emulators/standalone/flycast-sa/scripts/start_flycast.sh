#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 flycast"

#Check if flycast exists in .config
if [ ! -d "/storage/.config/flycast" ]; then
    mkdir -p "/storage/.config/flycast"
        cp -r "/usr/config/flycast" "/storage/.config/"
fi

#Move save file storage/roms
if [ -d "/storage/.config/flycast/data" ]; then
        mv "/storage/.config/flycast/data" "/storage/roms/dreamcast/"
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

  #AspectRatio
        if [ "$ASPECT" = "4/3" ]
        then
                sed -i '/^rend.WideScreen =/c\rend.WideScreen = no' /storage/.config/flycast/emu.cfg
                sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = no' /storage/.config/flycast/emu.cfg
        fi
        if [ "$ASPECT" = "w" ]
        then
                sed -i '/^rend.WideScreen =/c\rend.WideScreen = yes' /storage/.config/flycast/emu.cfg
                sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = no' /storage/.config/flycast/emu.cfg
        fi
        if [ "$ASPECT" = "sw" ]
        then
                sed -i '/^rend.WideScreen =/c\rend.WideScreen = yes' /storage/.config/flycast/emu.cfg
                sed -i '/^rend.SuperWideScreen =/c\rend.SuperWideScreen = yes' /storage/.config/flycast/emu.cfg
        fi

  #AutoFrameSkip
        if [ "$ASKIP" = "off" ]
        then
                sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 0' /storage/.config/flycast/emu.cfg
        fi
        if [ "$ASKIP" = "normal" ]
        then
                sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 1' /storage/.config/flycast/emu.cfg
        fi
        if [ "$ASKIP" = "max" ]
        then
                sed -i '/^pvr.AutoSkipFrame =/c\pvr.AutoSkipFrame = 2' /storage/.config/flycast/emu.cfg
        fi

  #Renderer
        if [ "$RENDERER" = "opengl" ]
        then
                sed -i '/^pvr.rend =/c\pvr.rend = 0' /storage/.config/flycast/emu.cfg
        fi
        if [ "$RENDERER" = "vulkan" ]
        then
                sed -i '/^pvr.rend =/c\pvr.rend = 4' /storage/.config/flycast/emu.cfg
        fi

  #ShowFPS
	if [ "$FPS" = "0" ]
	then
	        sed -i '/^rend.ShowFPS =/c\rend.ShowFPS = no' /storage/.config/flycast/emu.cfg
	fi
        if [ "$FPS" = "1" ]
        then
                sed -i '/^rend.ShowFPS =/c\rend.ShowFPS = yes' /storage/.config/flycast/emu.cfg
        fi

  #Vysnc
	if [ "$VSYNC" = "0" ]
	then
                sed -i '/^rend.vsync =/c\rend.vsync = no' /storage/.config/flycast/emu.cfg
	fi
        if [ "$VSYNC" = "1" ]
        then
                sed -i '/^rend.vsync =/c\rend.vsync = yes' /storage/.config/flycast/emu.cfg
        fi

#Run flycast emulator
${EMUPERF} /usr/bin/flycast "${1}"
