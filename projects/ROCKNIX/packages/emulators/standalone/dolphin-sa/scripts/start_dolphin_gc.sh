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

# Conf files vars
CONF_DIR="/storage/.config/dolphin-emu"
DOLPHIN_INI="Dolphin.ini"
GFX_INI="GFX.ini"
CONTROLLER_INI="GCPadNew.ini"

# Check if dolphin-emu exists in .config
if [ ! -d "${CONF_DIR}" ]; then
        cp -r "/usr/config/dolphin-emu" "/storage/.config/"
fi

# Check if Hotkeys.ini exists
if [ "${DOLPHIN_CORE}" = 'dolphin-emu' ]; then
  if [ ! -f "${CONF_DIR}/Hotkeys.ini" ]; then
        cp -r "/usr/config/dolphin-emu/Hotkeys.ini" "${CONF_DIR}/"
  fi
fi

# Check if GC controller dir exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -d "${CONF_DIR}/GamecubeControllerProfiles" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles" "${CONF_DIR}/"
fi

# Check if GC custom east profile exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -f "${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.east" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.east" "${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.east"
fi

# Check if GC custom controller profile exists in .config/dolphin-emu/GamecubeControllerProfiles
if [ ! -f "${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.custom" ]; then
        cp -r "/usr/config/dolphin-emu/GamecubeControllerProfiles/GCPadNew.ini.south" "${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.custom"
fi

# Link Save States to /roms/savestates/gamecube
if [ ! -d "/storage/roms/savestates/gamecube/" ]; then
    mkdir -p "/storage/roms/savestates/gamecube/"
fi

rm -rf ${CONF_DIR}/StateSaves
ln -sf /storage/roms/savestates/gamecube ${CONF_DIR}/StateSaves

# Copy bios, memory cards and other system stuff to roms
if [ ! -d "/storage/roms/bios/GC/" ]; then
    mkdir -p /storage/roms/bios/GC/{USA,JAP,EUR}
    cp -r ${CONF_DIR}/GC /storage/roms/bios/
fi

# Link bios and memory cards to roms
for REGION in EUR JAP USA
do
  # Link bios
  rm -rf "${CONF_DIR}/GC/${REGION}"
  ln -sf "/storage/roms/bios/GC/${REGION}" "${CONF_DIR}/GC/${REGION}"

  # Link memory cards, copying to roms/bios first as needed
  for SLOT in A B
  do
    MEM_CARD_FILE="MemoryCard${SLOT}.${REGION}.raw"
    CONFIG_MEM_CARD="${CONF_DIR}/GC/${MEM_CARD_FILE}"
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
ASWAPDISCS=$(get_setting auto_swap_discs "${PLATFORM}" "${GAME}")
CLOCK=$(get_setting clock_speed "${PLATFORM}" "${GAME}")
ENBCHEATS=$(get_setting enable_cheats "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
CON=$(get_setting gamecube_controller_profile "${PLATFORM}" "${GAME}")
HKEY=$(get_setting hotkey_enable_button "${PLATFORM}" "${GAME}")
SAVETYPE=$(get_setting save_type "${PLATFORM}" "${GAME}")
SAVEREG=$(get_setting save_gci_region "${PLATFORM}" "${GAME}")
SHADERM=$(get_setting shader_mode "${PLATFORM}" "${GAME}")
SHADERP=$(get_setting shader_precompile "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
SKIPBIOS=$(get_setting use_bios "${PLATFORM}" "${GAME}")
EFBACCESS=$(get_setting skip_efb_cpu_access "${PLATFORM}" "${GAME}")
EFBTEXTURE=$(get_setting store_efb_to_texture_only "${PLATFORM}" "${GAME}")
XFBTEXTURE=$(get_setting store_xfb_to_texture_only "${PLATFORM}" "${GAME}")
TEXTURE_CACHE_ACCURACY=$(get_setting texture_cache_accuracy "${PLATFORM}" "${GAME}")
RUMBLE=$(get_setting rumble "${PLATFORM}" "${GAME}")
WHACK=$(get_setting widescreen_hack "${PLATFORM}" "${GAME}")
WPC=$(get_setting write_protect_configs "${PLATFORM}" "${GAME}")

# Grab clean config files during boot, unless disabled in emulationstation
if [ "$WPC" != "false" ]; then
  cp -r /usr/config/dolphin-emu/GFX.ini ${CONF_DIR}/${GFX_INI}
  cp -r /usr/config/dolphin-emu/Dolphin.ini ${CONF_DIR}/${DOLPHIN_INI}
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
    sed -i '/MSAA/c\MSAA = 2' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = False' ${CONF_DIR}/${GFX_INI}
  elif [ "$AA" = "2s" ]; then
    sed -i '/MSAA/c\MSAA = 2' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = True' ${CONF_DIR}/${GFX_INI}
  elif [ "$AA" = "4m" ]; then
    sed -i '/MSAA/c\MSAA = 4' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = False' ${CONF_DIR}/${GFX_INI}
  elif [ "$AA" = "4s" ]; then
    sed -i '/MSAA/c\MSAA = 4' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = True' ${CONF_DIR}/${GFX_INI}
  elif [ "$AA" = "8m" ]; then
    sed -i '/MSAA/c\MSAA = 8' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = False' ${CONF_DIR}/${GFX_INI}
  elif [ "$AA" = "8s" ]; then
    sed -i '/MSAA/c\MSAA = 8' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = True' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/MSAA/c\MSAA = 0' ${CONF_DIR}/${GFX_INI}
    sed -i '/SSAA/c\SSAA = False' ${CONF_DIR}/${GFX_INI}
  fi

  # Aspect Ratio
  if [ "$ASPECT" = "1" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 1' ${CONF_DIR}/${GFX_INI}
  elif [ "$ASPECT" = "2" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 2' ${CONF_DIR}/${GFX_INI}
  elif [ "$ASPECT" = "3" ]; then
    sed -i '/AspectRatio/c\AspectRatio = 3' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/AspectRatio/c\AspectRatio = 0' ${CONF_DIR}/${GFX_INI}
  fi

  # Audio Backend
  if [ "$AUDIOBE" = "lle" ]; then
    AUDIO_BACKEND="LLE"
  else
    AUDIO_BACKEND="HLE"
  fi

  # Auto Swap Discs
  if [ "$ASWAPDISCS" = "0" ]; then
    sed -i '/AutoDiscChange/c\AutoDiscChange = False' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/AutoDiscChange/c\AutoDiscChange = True' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Clock Speed
  if [ "$CLOCK" = "050" ]; then
    sed -i '/^Overclock =/c\Overclock = 0.5' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "075" ]; then
    sed -i '/^Overclock =/c\Overclock = 0.75' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "100" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.0' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = False' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "125" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.25' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "150" ]; then
    sed -i '/^Overclock =/c\Overclock = 1.5' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "200" ]; then
    sed -i '/^Overclock =/c\Overclock = 2.0' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "300" ]; then
    sed -i '/^Overclock =/c\Overclock = 3.0' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$CLOCK" = "400" ]; then
    sed -i '/^Overclock =/c\Overclock = 4.0' ${CONF_DIR}/${DOLPHIN_INI}
    sed -i '/^OverclockEnable =/c\OverclockEnable = True' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/^OverclockEnable =/c\OverclockEnable = False' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Enable Cheats
  if [ "$ENBCHEATS" = "1" ]; then
    sed -i '/EnableCheats/c\EnableCheats = True' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/EnableCheats/c\EnableCheats = False' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Graphics Backend
  if [ "$GRENDERER" = "vulkan" ]; then
    sed -i '/GFXBackend/c\GFXBackend = Vulkan' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$GRENDERER" = "opengl" ]; then
    sed -i '/GFXBackend/c\GFXBackend = OGL' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/GFXBackend/c\GFXBackend = @GRENDERER@' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Internal Resolution
  if [ "$IRES" = "1" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 1' ${CONF_DIR}/${GFX_INI}
  elif [ "$IRES" = "3" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 3' ${CONF_DIR}/${GFX_INI}
  elif [ "$IRES" = "4" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 4' ${CONF_DIR}/${GFX_INI}
  elif [ "$IRES" = "6" ]; then
    sed -i '/InternalResolution/c\InternalResolution = 6' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/InternalResolution/c\InternalResolution = 2' ${CONF_DIR}/${GFX_INI}
  fi

  # Save Type
  if [ "$SAVETYPE" = "8" ]; then
    sed -i '/SlotA/c\SlotA = 8' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/SlotA/c\SlotA = 1' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Save Reg
  if [ "$SAVEREG" = "eur" ]; then
    sed -i '/GCIFolderAPath/c\GCIFolderAPath = \/storage\/roms\/bios\/GC\/EUR' ${CONF_DIR}/${DOLPHIN_INI}
  elif [ "$SAVEREG" = "jap" ]; then
    sed -i '/GCIFolderAPath/c\GCIFolderAPath = \/storage\/roms\/bios\/GC\/JAP' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/GCIFolderAPath/c\GCIFolderAPath = \/storage\/roms\/bios\/GC\/USA' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Shader Mode
  if [ "$SHADERM" = "0" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 0' ${CONF_DIR}/${GFX_INI}
  elif [ "$SHADERM" = "1" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 1' ${CONF_DIR}/${GFX_INI}
  elif [ "$SHADERM" = "2" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 2' ${CONF_DIR}/${GFX_INI}
  elif [ "$SHADERM" = "3" ]; then
    sed -i '/ShaderCompilationMode =/c\ShaderCompilationMode = 3' ${CONF_DIR}/${GFX_INI}
  fi

  #Shader Precompile
  if [ "$SHADERP" = "false" ]; then
    sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = False' ${CONF_DIR}/${GFX_INI}
  elif [ "$SHADERP" = "true" ]; then
    sed -i '/WaitForShadersBeforeStarting =/c\WaitForShadersBeforeStarting = True' ${CONF_DIR}/${GFX_INI}
  fi

  # Show FPS
  if [ "$FPS" = "true" ]; then
    sed -i '/ShowFPS/c\ShowFPS = True' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/ShowFPS/c\ShowFPS = False' ${CONF_DIR}/${GFX_INI}
  fi

  # Skip Bios
  if [ "$SKIPBIOS" = "false" ]; then
    sed -i '/SkipIPL/c\SkipIPL = False' ${CONF_DIR}/${DOLPHIN_INI}
  else
    sed -i '/SkipIPL/c\SkipIPL = True' ${CONF_DIR}/${DOLPHIN_INI}
  fi

  # Skip EFB CPU Access
  if [ "$EFBACCESS" = "false" ]; then
    sed -i '/EFBAccessEnable =/c\EFBAccessEnable = False' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/EFBAccessEnable =/c\EFBAccessEnable = True' ${CONF_DIR}/${GFX_INI}
  fi

  # Store EFB to texture only
  if [ "$EFBTEXTURE" = "false" ]; then
    sed -i '/EFBToTextureEnable =/c\EFBToTextureEnable = False' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/EFBToTextureEnable =/c\EFBToTextureEnable = True' ${CONF_DIR}/${GFX_INI}
  fi

  # Store XFB to texture only
  if [ "$XFBTEXTURE" = "false" ]; then
    sed -i '/XFBToTextureEnable =/c\XFBToTextureEnable = False' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/XFBToTextureEnable =/c\XFBToTextureEnable = True' ${CONF_DIR}/${GFX_INI}
  fi

  # Texture cache accuracy
  if [ "$TEXTURE_CACHE_ACCURACY" = "0" ]; then
    sed -i '/SafeTextureCacheColorSamples =/c\SafeTextureCacheColorSamples = 0' ${CONF_DIR}/${GFX_INI}
  elif [ "$TEXTURE_CACHE_ACCURACY" = "512" ]; then
    sed -i '/SafeTextureCacheColorSamples =/c\SafeTextureCacheColorSamples = 512' ${CONF_DIR}/${GFX_INI}
  else
    # Default to 128 = fast
    sed -i '/SafeTextureCacheColorSamples =/c\SafeTextureCacheColorSamples = 128' ${CONF_DIR}/${GFX_INI}
  fi

  # Widescreen Hack
  if [ "$WHACK" = "true" ]; then
    sed -i '/wideScreenHack =/c\wideScreenHack = True' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/wideScreenHack =/c\wideScreenHack = False' ${CONF_DIR}/${GFX_INI}
  fi

  # GC Controller Profile
  if [ "$CON" = "east" ]; then
    cp -r ${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.east ${CONF_DIR}/${CONTROLLER_INI}
  elif [ "$CON" = "custom" ]; then
    cp -r ${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.custom ${CONF_DIR}/${CONTROLLER_INI}
  else
    cp -r ${CONF_DIR}/GamecubeControllerProfiles/GCPadNew.ini.south ${CONF_DIR}/${CONTROLLER_INI}
  fi

  # GC Controller Rumble
  if [ "$RUMBLE" = "false" ]; then
    sed -i '/^Rumble/d' ${CONF_DIR}/${CONTROLLER_INI}
  fi

  # GC Controller Hotkey Enable
  if [ "$HKEY" = "mode" ]; then
    sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 8' ${CONF_DIR}/${CONTROLLER_INI}
  else
    sed -i '/^Buttons\/Hotkey =/c\Buttons\/Hotkey = Button 6' ${CONF_DIR}/${CONTROLLER_INI}
  fi

  # Vsync
  if [ "$VSYNC" = "1" ]; then
    sed -i '/VSync =/c\VSync = True' ${CONF_DIR}/${GFX_INI}
  else
    sed -i '/VSync =/c\VSync = False' ${CONF_DIR}/${GFX_INI}
  fi

# Link  .config/dolphin-emu to .local
rm -rf /storage/.local/share/dolphin-emu
ln -sf /storage/.config/dolphin-emu /storage/.local/share/dolphin-emu

# Retroachievements
  /usr/bin/cheevos_dolphin.sh

# Set video and audio backend
  CMD="${CMD} -v $GRENDERER"

if [ ${DOLPHIN_CORE} = "dolphin-emu" ]; then
  CMD="-b -a ${AUDIO_BACKEND}"
else
  CMD="-p @DOLPHIN_BACKEND@ -a ${AUDIO_BACKEND}"
fi

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "AA set to: ${AA}"
  echo "ASPECT set to: ${ASPECT}"
  echo "AUDIOBE set to: ${AUDIOBE}"
  echo "ASWAPDISCS set to: ${ASWAPDISCS}"
  echo "CLOCK set to: ${CLOCK}"
  echo "ENBCHEATS set to: ${ENBCHEATS}"
  echo "GRENDERER set to: ${GRENDERER}"
  echo "IRES set to: ${IRES}"
  echo "FPS set to: ${FPS}"
  echo "CON set to: ${CON}"
  echo "HKEY set to: ${HKEY}"
  echo "SAVETYPE set to: ${SAVETYPE}"
  echo "SAVEREG set to: ${SAVEREG}"
  echo "SHADERM set to: ${SHADERM}"
  echo "SHADERP set to: ${SHADERP}"
  echo "VSYNC set to: ${VSYNC}"
  echo "SKIPBIOS set to: ${SKIPBIOS}"
  echo "EFBACCESS set to: ${EFBACCESS}"
  echo "EFBTEXTURE set to: ${EFBTEXTURE}"
  echo "XFBTEXTURE set to: ${XFBTEXTURE}"
  echo "TEXTURE_CACHE_ACCURACY set to: ${TEXTURE_CACHE_ACCURACY}"
  echo "RUMBLE set to: ${RUMBLE}"
  echo "WHACK set to: ${WHACK}"
  echo "WPC set to: ${WPC}"
  echo "Launching /usr/bin/${DOLPHIN_CORE} ${CMD} -e ${1}"

# Run Dolphin emulator
  @EXPORTS@
  ${GPTOKEYB} ${DOLPHIN_CORE} xbox360 &
  ${EMUPERF} /usr/bin/${DOLPHIN_CORE} ${CMD} -e "${1}"
  kill -9 "$(pidof gptokeyb)"
