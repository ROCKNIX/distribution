#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

#Check if aethersx2 exists in .config
if [ ! -d "/storage/.config/aethersx2" ]; then
    mkdir -p "/storage/.config/aethersx2"
        cp -r "/usr/config/aethersx2" "/storage/.config/"
fi

#Make Aethersx2 bios folder
if [ ! -d "/storage/roms/bios/aethersx2" ]; then
    mkdir -p "/storage/roms/bios/aethersx2"
fi

#Create PS2 savestates folder
if [ ! -d "/storage/roms/savestates/ps2" ]; then
    mkdir -p "/storage/roms/savestates/ps2"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
FILTER=$(get_setting bilinear_filtering "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
RATE=$(get_setting ee_cycle_rate "${PLATFORM}" "${GAME}")
SKIP=$(get_setting ee_cycle_skip "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
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
  #All..
  unset EMUPERF
fi

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = 4:3' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
	if [ "$ASPECT" = "1" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = 16:9' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
	if [ "$ASPECT" = "2" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = Stretch' /storage/.config/aethersx2/inis/PCSX2.ini
	fi

  #Bilinear Filtering
        if [ "$FILTER" = "0" ]
        then
                sed -i '/^filter =/c\filter = 0' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "1" ]
        then
                sed -i '/^filter =/c\filter = 1' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "2" ]
        then
                sed -i '/^filter =/c\filter = 2' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "3" ]
        then
                sed -i '/^filter =/c\filter = 3' /storage/.config/aethersx2/inis/PCSX2.ini
        fi

  #Graphics Backend
	if [ "$GRENDERER" = "0" ]
	then
  		sed -i '/^Renderer =/c\Renderer = -1' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
	if [ "$GRENDERER" = "1" ]
	then
  		sed -i '/^Renderer =/c\Renderer = 12' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
	if [ "$GRENDERER" = "2" ]
	then
  		sed -i '/^Renderer =/c\Renderer = 14' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
        if [ "$GRENDERER" = "3" ]
        then
                sed -i '/^Renderer =/c\Renderer = 13' /storage/.config/aethersx2/inis/PCSX2.ini
        fi

  #Internal Resolution
        if [ "$IRES" > "0" ]
        then
                sed -i "/^upscale_multiplier =/c\upscale_multiplier = $IRES" /storage/.config/aethersx2/inis/PCSX2.ini
        else
                sed -i '/^upscale_multiplier =/c\upscale_multiplier = 1' /storage/.config/aethersx2/inis/PCSX2.ini
        fi

  #Show FPS
	if [ "$FPS" = "false" ]
	then
  		sed -i '/^OsdShowFPS =/c\OsdShowFPS = false' /storage/.config/aethersx2/inis/PCSX2.ini
	fi
	if [ "$FPS" = "true" ]
	then
  		sed -i '/^OsdShowFPS =/c\OsdShowFPS = true' /storage/.config/aethersx2/inis/PCSX2.ini
	fi

  #EE Cycle Rate
        sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/aethersx2/inis/PCSX2.ini
        if [ "$RATE" = "0" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -3' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "1" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -2' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "2" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -1' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "3" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "4" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 1' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "5" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 2' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "6" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 3' /storage/.config/aethersx2/inis/PCSX2.ini
        fi

  #EE Cycle Skip
        sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/aethersx2/inis/PCSX2.ini
        if [ "$SKIP" = "0" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "1" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 1' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "2" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 2' /storage/.config/aethersx2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "3" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 3' /storage/.config/aethersx2/inis/PCSX2.ini
        fi

#Set OpenGL 3.3 on panfrost
  export MESA_GL_VERSION_OVERRIDE=3.3
  export MESA_GLSL_VERSION_OVERRIDE=330

#Set QT enviornment to wayland
  export QT_QPA_PLATFORM=wayland

# Extra Libs needed to run
  export LD_LIBRARY_PATH=/usr/share/aethersx2-sa/libs

#Run Aethersx2 emulator
  export SDL_AUDIODRIVER=pulseaudio
  set_kill set "-9 aethersx2"
  ${EMUPERF} /usr/share/aethersx2-sa/aethersx2 -bigpicture -fullscreen "${1}"
