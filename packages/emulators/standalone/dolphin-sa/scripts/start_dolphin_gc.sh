#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 dolphin-emu-nogui"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

#Check if dolphin-emu exists in .config
if [ ! -d "/storage/.config/dolphin-emu" ]; then
    mkdir -p "/storage/.config/dolphin-emu"
        cp -r "/usr/config/dolphin-emu" "/storage/.config/"
fi

#Check if GC controller dir exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -d "/storage/.config/dolphin-emu/GamecubeControllerProfiles" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles" "/storage/.config/dolphin-emu/"
fi

#Check if GC custom controller profile exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -f "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south" "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom"
fi

#Link Save States to /roms/savestates
if [ ! -d "/storage/roms/savestates/gamecube/" ]; then
    mkdir -p "/storage/roms/savestates/gamecube/"
fi

rm -rf /storage/.config/dolphin-emu/StateSaves
ln -sf /storage/roms/savestates/gamecube /storage/.config/dolphin-emu/StateSaves

#Grab a clean settings file during boot
cp -r /usr/config/dolphin-emu/GFX.ini /storage/.config/dolphin-emu.GFX.ini
cp -r /usr/config/dolphin-emu/Dolphin.ini /storage/.config/dolphin-emu.Dolphin.ini

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
AA=$(get_setting anti_aliasing "${PLATFORM}" "${GAME}")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
CLOCK=$(get_setting clock_speed "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
CON=$(get_setting gamecube_controller_profile "${PLATFORM}" "${GAME}")
HKEY=$(get_setting hotkey_enable_button "${PLATFORM}" "${GAME}")
SHADERM=$(get_setting shader_mode "${PLATFORM}" "${GAME}")
SHADERP=$(get_setting shader_precompile "${PLATFORM}" "${GAME}")
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

  #Anti-Aliasing
	if [ "$AA" = "0" ]
	then
  		sed -i '/MSAA/c\MSAA = 0' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
	fi
	if [ "$AA" = "2m" ]
	then
  		sed -i '/MSAA/c\MSAA = 2' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
	fi
        if [ "$AA" = "2s" ]
        then
                sed -i '/MSAA/c\MSAA = 2' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
        fi
	if [ "$AA" = "4m" ]
	then
  		sed -i '/MSAA/c\MSAA = 4' /storage/.config/dolphin-emu/GFX.ini
                sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
	fi
        if [ "$AA" = "4s" ]
        then
                sed -i '/MSAA/c\MSAA = 4' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
        fi
	if [ "$AA" = "8m" ]
	then
  		sed -i '/MSAA/c\MSAA = 8' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
	fi
        if [ "$AA" = "8s" ]
        then
                sed -i '/MSAA/c\MSAA = 8' /storage/.config/dolphin-emu/GFX.ini
		sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
        fi

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]
	then
  		sed -i '/AspectRatio/c\AspectRatio = 0' /storage/.config/dolphin-emu/GFX.ini
	fi
	if [ "$ASPECT" = "1" ]
	then
  		sed -i '/AspectRatio/c\AspectRatio = 1' /storage/.config/dolphin-emu/GFX.ini
	fi
	if [ "$ASPECT" = "2" ]
	then
  		sed -i '/AspectRatio/c\AspectRatio = 2' /storage/.config/dolphin-emu/GFX.ini
	fi
	if [ "$ASPECT" = "3" ]
	then
  		sed -i '/AspectRatio/c\AspectRatio = 3' /storage/.config/dolphin-emu/GFX.ini
	fi

  #Clock Speed
	sed -i '/^OverclockEnable =/c\OverclockEnable = False' /storage/.config/dolphin-emu/Dolphin.ini
        if [ "$CLOCK" = "0" ]
        then
                sed -i '/^Overclock =/c\Overclock = 0.5' /storage/.config/dolphin-emu/Dolphin.ini
                sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
        fi
        if [ "$CLOCK" = "1" ]
        then
                sed -i '/^Overclock =/c\Overclock = 0.75' /storage/.config/dolphin-emu/Dolphin.ini
                sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
        fi
        if [ "$CLOCK" = "2" ]
        then
                sed -i '/^Overclock =/c\Overclock = 1.0' /storage/.config/dolphin-emu/Dolphin.ini
                sed -i '/^OverclockEnable =/c\OverclockEnable = False' /storage/.config/dolphin-emu/Dolphin.ini
        fi
        if [ "$CLOCK" = "3" ]
        then
                sed -i '/^Overclock =/c\Overclock = 1.25' /storage/.config/dolphin-emu/Dolphin.ini
                sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
        fi
        if [ "$CLOCK" = "4" ]
        then
                sed -i '/^Overclock =/c\Overclock = 1.5' /storage/.config/dolphin-emu/Dolphin.ini
                sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
        fi

  #Video Backend
	if [ "$RENDERER" = "opengl" ]
	then
  		sed -i '/GFXBackend/c\GFXBackend = OGL' /storage/.config/dolphin-emu/Dolphin.ini
	fi
	if [ "$RENDERER" = "vulkan" ]
	then
  		sed -i '/GFXBackend/c\GFXBackend = Vulkan' /storage/.config/dolphin-emu/Dolphin.ini
	fi
        if [ "$RENDERER" = "software" ]
        then
                sed -i '/GFXBackend/c\GFXBackend = Software Renderer' /storage/.config/dolphin-emu/Dolphin.ini
        fi

  #Internal Resolution
        if [ "$IRES" = "0" ]
        then
                sed -i '/InternalResolution/c\InternalResolution = 1' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$IRES" = "1" ]
        then
                sed -i '/InternalResolution/c\InternalResolution = 2' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$IRES" = "2" ]
        then
                sed -i '/InternalResolution/c\InternalResolution = 4' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$IRES" = "3" ]
        then
                sed -i '/InternalResolution/c\InternalResolution = 6' /storage/.config/dolphin-emu/GFX.ini
        fi

  #Shader Mode
        if [ "$SHADERM" = "0" ]
        then
                sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 0' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$SHADERM" = "1" ]
        then
                sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 1' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$SHADERM" = "2" ]
        then
                sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 2' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$SHADERM" = "3" ]
        then
                sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 3' /storage/.config/dolphin-emu/GFX.ini
        fi

  #Shader Precompile
        if [ "$SHADERP" = "false" ]
        then
                sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = False' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$SHADERP" = "true" ]
        then
                sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = True' /storage/.config/dolphin-emu/GFX.ini
        fi


  #Show FPS
	if [ "$FPS" = "false" ]
	then
  		sed -i '/ShowFPS/c\ShowFPS = False' /storage/.config/dolphin-emu/GFX.ini
	fi
	if [ "$FPS" = "true" ]
	then
  		sed -i '/ShowFPS/c\ShowFPS = true' /storage/.config/dolphin-emu/GFX.ini
	fi

  #GC Controller Profile
        if [ "$CON" = "south" ]
        then
                cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south /storage/.config/dolphin-emu/GCPadNew.ini
        elif [ "$CON" = "west" ]
        then
                cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.west /storage/.config/dolphin-emu/GCPadNew.ini
        elif [ "$CON" = "custom" ]
        then
                cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom /storage/.config/dolphin-emu/GCPadNew.ini
        else
		cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south /storage/.config/dolphin-emu/GCPadNew.ini
        fi

  #GC Controller Hotkey Enable
        if [ "$HKEY" = "mode" ]
        then
                sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 8' /storage/.config/dolphin-emu/GCPadNew.ini
        else
                sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 6' /storage/.config/dolphin-emu/GCPadNew.ini
        fi

  #VSYNC
        if [ "$VSYNC" = "0" ]
        then
                sed -i '/VSync =/c\VSync = False' /storage/.config/dolphin-emu/GFX.ini
        fi
        if [ "$VSYNC" = "1" ]
        then
                sed -i '/VSync =/c\VSync = True' /storage/.config/dolphin-emu/GFX.ini
        fi

#Link  .config/dolphin-emu to .local
rm -rf /storage/.local/share/dolphin-emu
ln -sf /storage/.config/dolphin-emu /storage/.local/share/dolphin-emu

@LIBMALI@

#Run Dolphin emulator
  ${GPTOKEYB} dolphin-emu-nogui xbox360 &
  ${EMUPERF} /usr/bin/dolphin-emu-nogui -p @DOLPHIN_PLATFORM@ -a HLE -e "${1}"
  kill -9 "$(pidof gptokeyb)"
