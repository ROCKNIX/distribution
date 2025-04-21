#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 melonDS"

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

if [ ! -d "/storage/.config/melonDS" ]; then
    mkdir -p "/storage/.config/melonDS"
        cp -r "/usr/config/melonDS" "/storage/.config/"
fi

if [ ! -d "/storage/roms/savestates/nds" ]; then
    mkdir -p "/storage/roms/savestates/nds"
fi

#Make sure melonDS gptk config exists
if [ ! -f "/storage/.config/melonDS/melonDS.gptk" ]; then
  cp -r "/usr/config/melonDS/melonDS.gptk" "/storage/.config/melonDS/melonDS.gptk"
fi

#Emulation Station Features
  GAME=$(echo "${1}"| sed "s#^/.*/##")
  GRENDERER=$(get_setting graphics_backend nds "${GAME}")
  SORIENTATION=$(get_setting screen_orientation nds "${GAME}")
  SLAYOUT=$(get_setting screen_layout nds "${GAME}")
  SWAP=$(get_setting screen_swap nds "${GAME}")
  SROTATION=$(get_setting screen_rotation nds "${GAME}")
  SHOWFPS=$(get_setting show_fps nds "${GAME}")
  SUI=$(get_setting start_ui nds "${GAME}")
  VSYNC=$(get_setting vsync nds "${GAME}")

  #Graphics Backend
	if [ "$GRENDERER" = "0" ]
	then
  		sed -i '/^ScreenUseGL=/c\ScreenUseGL=0' /storage/.config/melonDS/melonDS.ini
	fi
	if [ "$GRENDERER" = "1" ]
	then
  		sed -i '/^ScreenUseGL=/c\ScreenUseGL=1' /storage/.config/melonDS/melonDS.ini
	fi

  #Screen Orientation
	if [ "$SORIENTATION" > "0" ]
	then
		sed -i "/^ScreenLayout=/c\ScreenLayout=$SORIENTATION" /storage/.config/melonDS/melonDS.ini
	else
		sed -i '/^ScreenLayout=/c\ScreenLayout=2' /storage/.config/melonDS/melonDS.ini
        fi

  #Screen Layout
	if [ "$SLAYOUT" > "0" ]
	then
		sed -i "/^ScreenSizing=/c\ScreenSizing=$SLAYOUT" /storage/.config/melonDS/melonDS.ini
	else
		sed -i '/^ScreenSizing=/c\ScreenSizing=0' /storage/.config/melonDS/melonDS.ini
	fi

  #Screen Swap
	if [ "$SWAP" = "1" ]
	then
		sed -i '/^ScreenSwap=/c\ScreenSwap=1' /storage/.config/melonDS/melonDS.ini
	else
		sed -i '/^ScreenSwap=/c\ScreenSwap=0' /storage/.config/melonDS/melonDS.ini
	fi

  #Screen Rotation
	if [ "$SROTATION" > "0" ]
	then
		sed -i "/^ScreenRotation=/c\ScreenRotation=$SROTATION" /storage/.config/melonDS/melonDS.ini
	else
		sed -i '/^ScreenRotation=/c\ScreenRotation=0' /storage/.config/melonDS/melonDS.ini
	fi

  #Vsync
        if [ "$VSYNC" = "0" ]
        then
                sed -i '/^ScreenVSync=/c\ScreenVSync=0' /storage/.config/melonDS/melonDS.ini
        fi
        if [ "$VSYNC" = "1" ]
        then
                sed -i '/^ScreenVSync=/c\ScreenVSync=1' /storage/.config/melonDS/melonDS.ini
        fi

  #Show FPS
	if [ "$SHOWFPS" = "1" ]
	then
		export GALLIUM_HUD="simple,fps"
	fi

#Set QT Platform to Wayland
  export QT_QPA_PLATFORM=wayland
  @PANFROST@
  @HOTKEY@
  @LIBMALI@

#Run MelonDS emulator
	if [ "$SUI" = "1" ]
	then
                $GPTOKEYB "melonDS" -c "/storage/.config/melonDS/melonDS.gptk" &
		/usr/bin/melonDS
	else
		$GPTOKEYB "melonDS" -c "/storage/.config/melonDS/melonDS.gptk" &
		/usr/bin/melonDS -f "${1}"
	fi
                kill -9 "$(pidof gptokeyb)"
