#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

# Detect version of Dolphin
DOLPHIN_CORE=$(echo "${3}"| sed "s#^/.*/##")
if [ "${DOLPHIN_CORE}" = 'dolphin-qt-gc' ]; then
  DOLPHIN_CORE="dolphin-emu"
else
  DOLPHIN_CORE="dolphin-emu-nogui"
fi

set_kill set "-9 ${DOLPHIN_CORE}"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

# Check if dolphin-emu exists in .config
if [ ! -d "/storage/.config/dolphin-emu" ]; then
    mkdir -p "/storage/.config/dolphin-emu"
        cp -r "/usr/config/dolphin-emu" "/storage/.config/"
fi

# Check if Hotkeys.ini exists
if [ "${DOLPHIN_CORE}" = 'dolphin-emu' ]; then
  if [ ! -f "/storage/.config/dolphin-emu/Hotkeys.ini" ]; then
        cp -r "/usr/config/dolphin-emu/Hotkeys.ini" "/storage/.config/dolphin-emu/"
  fi
fi

# Check if GC controller dir exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -d "/storage/.config/dolphin-emu/GamecubeControllerProfiles" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles" "/storage/.config/dolphin-emu/"
fi

# Check if GC custom east profile exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -f "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.east" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.east" "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.east"
fi

# Check if GC custom controller profile exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -f "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south" "/storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom"
fi

# Link Save States to /roms/savestates/gamecube
if [ ! -d "/storage/roms/savestates/gamecube/" ]; then
    mkdir -p "/storage/roms/savestates/gamecube/"
fi

rm -rf /storage/.config/dolphin-emu/StateSaves
ln -sf /storage/roms/savestates/gamecube /storage/.config/dolphin-emu/StateSaves

# Copy bios, memory cards and other system stuff to roms
if [ ! -d "/storage/roms/bios/GC/" ]; then
    mkdir -p /storage/roms/bios/GC/{USA,JAP,EUR}
    cp -r /storage/.config/dolphin-emu/GC /storage/roms/bios/
fi

# Link bios and memory cards to roms
for REGION in EUR JAP USA
do
  # Link bios
  rm -rf "/storage/.config/dolphin-emu/GC/${REGION}"
  ln -sf "/storage/roms/bios/GC/${REGION}" "/storage/.config/dolphin-emu/GC/${REGION}"

  # Link memory cards, copying to roms/bios first as needed
  for SLOT in A B
  do
    MEM_CARD_FILE="MemoryCard${SLOT}.${REGION}.raw"
    CONFIG_MEM_CARD="/storage/.config/dolphin-emu/GC/${MEM_CARD_FILE}"
    ROMS_BIOS_MEM_CARD="/storage/roms/bios/GC/${MEM_CARD_FILE}"

    if [ -f "${ROMS_BIOS_MEM_CARD}" ]; then
      # Exists in roms/bios, remove from .config and link
      rm -f "${CONFIG_MEM_CARD}"
      ln -sf "${ROMS_BIOS_MEM_CARD}" "${CONFIG_MEM_CARD}"
    elif [ -f "${CONFIG_MEM_CARD}" ]; then
      # Only exists in .config, move to roms/bios and link
      mv -f "${CONFIG_MEM_CARD}" "${ROMS_BIOS_MEM_CARD}"
      ln -sf "${ROMS_BIOS_MEM_CARD}" "${CONFIG_MEM_CARD}"
    fi
  done
done

# Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
AA=$(get_setting anti_aliasing "${PLATFORM}" "${GAME}")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
AUDIOBE=$(get_setting audio_backend "${PLATFORM}" "${GAME}")
CLOCK=$(get_setting clock_speed "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
CON=$(get_setting gamecube_controller_profile "${PLATFORM}" "${GAME}")
HKEY=$(get_setting hotkey_enable_button "${PLATFORM}" "${GAME}")
SAVETYPE=$(get_setting save_type "${PLATFORM}" "${GAME}")
SHADERM=$(get_setting shader_mode "${PLATFORM}" "${GAME}")
SHADERP=$(get_setting shader_precompile "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
SKIPBIOS=$(get_setting use_bios "${PLATFORM}" "${GAME}")
EFBACCESS=$(get_setting skip_efb_cpu_access "${PLATFORM}" "${GAME}")
EFBTEXTURE=$(get_setting store_efb_to_texture_only "${PLATFORM}" "${GAME}")
XFBTEXTURE=$(get_setting store_xfb_to_texture_only "${PLATFORM}" "${GAME}")
RUMBLE=$(get_setting rumble "${PLATFORM}" "${GAME}")
WHACK=$(get_setting widescreen_hack "${PLATFORM}" "${GAME}")
WPC=$(get_setting write_protect_configs "${PLATFORM}" "${GAME}")

# Grab clean config files during boot, unless disabled in emulationstation
if [ "$WPC" != "false" ]; then
  cp -r /usr/config/dolphin-emu/GFX.ini /storage/.config/dolphin-emu/GFX.ini
  cp -r /usr/config/dolphin-emu/Dolphin.ini /storage/.config/dolphin-emu/Dolphin.ini
fi


# Set the cores to use
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

### Emulation Station features:
  # Anti-Aliasing
  if [ "$AA" = "2m" ]; then
    sed -i '/MSAA/c\MSAA = 2' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$AA" = "2s" ]; then
    sed -i '/MSAA/c\MSAA = 2' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$AA" = "4m" ]; then
    sed -i '/MSAA/c\MSAA = 4' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$AA" = "4s" ]; then
    sed -i '/MSAA/c\MSAA = 4' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$AA" = "8m" ]; then
    sed -i '/MSAA/c\MSAA = 8' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$AA" = "8s" ]; then
    sed -i '/MSAA/c\MSAA = 8' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = True' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/MSAA/c\MSAA = 0' /storage/.config/dolphin-emu/GFX.ini
    sed -i '/SSAA/c\SSAA = False' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Aspect Ratio
  if [ "$ASPECT" = "1" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 1' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$ASPECT" = "2" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 2' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$ASPECT" = "3" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 3' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/AspectRatio/c\AspectRatio = 0' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Audio Backend
  if [ "$AUDIOBE" = "lle" ]; then
    AUDIO_BACKEND="LLE"
  else
    AUDIO_BACKEND="HLE"
  fi

  # Clock Speed
  if [ "$CLOCK" = "050" ]; then
    sed -i '/^Overclock =/c\Overclock = 0.5' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "075" ]; then
    sed -i '/^Overclock =/c\Overclock = 0.75' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "100" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.0' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = False' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "125" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.25' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "150" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.5' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "200" ]; then
    sed -i '/^Overclock =/c\Overclock = 2.0' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "300" ]; then
    sed -i '/^Overclock =/c\Overclock = 3.0' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  elif [ "$CLOCK" = "400" ]; then
    sed -i '/^Overclock =/c\Overclock = 4.0' /storage/.config/dolphin-emu/Dolphin.ini
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' /storage/.config/dolphin-emu/Dolphin.ini
  else
    sed -i '/^OverclockEnable =/c\OverclockEnable = False' /storage/.config/dolphin-emu/Dolphin.ini
  fi

  # Graphics Backend
  if [ "$RENDERER" = "vulkan" ]; then
    sed -i '/GFXBackend/c\GFXBackend = Vulkan' /storage/.config/dolphin-emu/Dolphin.ini
  else
    sed -i '/GFXBackend/c\GFXBackend = OGL' /storage/.config/dolphin-emu/Dolphin.ini
  fi

  # Internal Resolution
  if [ "$IRES" = "1" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 1' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$IRES" = "3" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 3' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$IRES" = "4" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 4' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$IRES" = "6" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 6' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/InternalResolution/c\InternalResolution = 2' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Save Type
  if [ "$SAVETYPE" = "8" ]; then
    sed -i '/SlotA/c\SlotA = 8' /storage/.config/dolphin-emu/Dolphin.ini
  else
    sed -i '/SlotA/c\SlotA = 1' /storage/.config/dolphin-emu/Dolphin.ini
  fi

  # Shader Mode
  if [ "$SHADERM" = "0" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 0' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$SHADERM" = "1" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 1' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$SHADERM" = "2" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 2' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$SHADERM" = "3" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 3' /storage/.config/dolphin-emu/GFX.ini
  fi

  #Shader Precompile
  if [ "$SHADERP" = "false" ]; then
    sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = False' /storage/.config/dolphin-emu/GFX.ini
  elif [ "$SHADERP" = "true" ]; then
    sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = True' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Show FPS
  if [ "$FPS" = "true" ]; then
    sed -i '/ShowFPS/c\ShowFPS = True' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/ShowFPS/c\ShowFPS = False' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Skip Bios
  if [ "$SKIPBIOS" = "false" ]; then
    sed -i '/SkipIPL/c\SkipIPL = False' /storage/.config/dolphin-emu/Dolphin.ini
  else
    sed -i '/SkipIPL/c\SkipIPL = True' /storage/.config/dolphin-emu/Dolphin.ini
  fi

  # Skip EFB CPU Access
  if [ "$EFBACCESS" = "false" ]; then
    sed -i '/EFBAccessEnable =/c\EFBAccessEnable = False' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/EFBAccessEnable =/c\EFBAccessEnable = True' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Store EFB to texture only
  if [ "$EFBTEXTURE" = "false" ]; then
    sed -i '/EFBToTextureEnable =/c\EFBToTextureEnable = False' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/EFBToTextureEnable =/c\EFBToTextureEnable = True' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Store EFB to texture only
  if [ "$XFBTEXTURE" = "false" ]; then
    sed -i '/XFBToTextureEnable =/c\XFBToTextureEnable = False' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/XFBToTextureEnable =/c\XFBToTextureEnable = True' /storage/.config/dolphin-emu/GFX.ini
  fi

  # Widescreen Hack
  if [ "$WHACK" = "true" ]; then
    sed -i '/wideScreenHack =/c\wideScreenHack = True' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/wideScreenHack =/c\wideScreenHack = False' /storage/.config/dolphin-emu/GFX.ini
  fi

  # GC Controller Profile
  if [ "$CON" = "east" ]; then
    cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.east /storage/.config/dolphin-emu/GCPadNew.ini
  elif [ "$CON" = "custom" ]; then
    cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.custom /storage/.config/dolphin-emu/GCPadNew.ini
  else
    cp -r /storage/.config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south /storage/.config/dolphin-emu/GCPadNew.ini
  fi

  # GC Controller Rumble
  if [ "$RUMBLE" = "false" ]; then
    sed -i '/^Rumble/d' /storage/.config/dolphin-emu/GCPadNew.ini
  fi

  # GC Controller Hotkey Enable
  if [ "$HKEY" = "mode" ]; then
    sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 8' /storage/.config/dolphin-emu/GCPadNew.ini
  else
    sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 6' /storage/.config/dolphin-emu/GCPadNew.ini
  fi

  # Vsync
  if [ "$VSYNC" = "1" ]; then
    sed -i '/VSync =/c\VSync = True' /storage/.config/dolphin-emu/GFX.ini
  else
    sed -i '/VSync =/c\VSync = False' /storage/.config/dolphin-emu/GFX.ini
  fi

# Link  .config/dolphin-emu to .local
rm -rf /storage/.local/share/dolphin-emu
ln -sf /storage/.config/dolphin-emu /storage/.local/share/dolphin-emu

@EXPORTS@

# Retroachievements
/usr/bin/cheevos_dolphin.sh

# Set audio and video backend
if [ ${DOLPHIN_CORE} = "dolphin-emu" ]; then
  CMD="-b -a ${AUDIO_BACKEND}"
else
  CMD="-p @DOLPHIN_PLATFORM@ -a ${AUDIO_BACKEND}"
fi

# Run Dolphin emulator
  ${GPTOKEYB} ${DOLPHIN_CORE} xbox360 &
  ${EMUPERF} /usr/bin/${DOLPHIN_CORE} ${CMD} -e "${1}"
  kill -9 "$(pidof gptokeyb)"
