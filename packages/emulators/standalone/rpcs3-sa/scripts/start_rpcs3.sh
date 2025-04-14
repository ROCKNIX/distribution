#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

# Check if rpcs3 exists in .config
if [ ! -d "/storage/.config/rpcs3" ]; then
  cp -r "/usr/config/rpcs3" "/storage/.config/"
fi

# Link certain RPCS3 folders to a location in /storage/roms/bios
FOLDER_LINKS=("dev_flash" "dev_hdd0" "dev_hdd1" "custom_configs")
for FOLDER_LINK in "${FOLDER_LINKS[@]}"; do
  TARGET_FOLDER="/storage/roms/bios/rpcs3/$FOLDER_LINK"
  SOURCE_FOLDER="/storage/.config/rpcs3/$FOLDER_LINK"

  # Create the target folder if it doesn't exist
  if [ ! -d "$TARGET_FOLDER" ]; then
      mkdir -p "$TARGET_FOLDER"
  fi

  # Remove existing source folder
  rm -rf "$SOURCE_FOLDER"

  # Create symbolic link
  ln -sf "$TARGET_FOLDER" "$SOURCE_FOLDER"
done

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
ATEXTURE=$(get_setting async_texture_streaming "${PLATFORM}" "${GAME}")
FLIMIT=$(get_setting frame_limit "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IPS3RES=$(get_setting internal_ps3_resolution "${PLATFORM}" "${GAME}")
IRES_SCALE=$(get_setting internal_resolution_scale "${PLATFORM}" "${GAME}")
MULTIRSX=$(get_setting multithreaded_rsx "${PLATFORM}" "${GAME}")
PERFOVERLAY=$(get_setting performance_overlay "${PLATFORM}" "${GAME}")
SPREC=$(get_setting shader_precision "${PLATFORM}" "${GAME}")
SPUXFLOAT=$(get_setting spu_xfloat_accuracy "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
WCOLORB=$(get_setting write_color_buffers "${PLATFORM}" "${GAME}")
ZCULLA=$(get_setting zcull_accuracy "${PLATFORM}" "${GAME}")
SUI=$(get_setting start_ui "${PLATFORM}" "${GAME}")
CONFIG_YML="/storage/.config/rpcs3/config.yml"

#Aspect Ratio
if [ "${ASPECT}" = "4x3" ]; then
  sed -i "s#Aspect ratio:.*\$#Aspect ratio: 4:3#g" "${CONFIG_YML}"
else
  sed -i "s#Aspect ratio:.*\$#Aspect ratio: 16:9#g" "${CONFIG_YML}"
fi

#Asynchronous Texture Streaming
if [ "${ATEXTURE}" = "true" ]; then
  sed -i "s#Asynchronous Texture Streaming 2:.*\$#Asynchronous Texture Streaming 2: true#g" "${CONFIG_YML}"
else
  sed -i "s#Asynchronous Texture Streaming 2:.*\$#Asynchronous Texture Streaming 2: false#g" "${CONFIG_YML}"
fi

#Graphics Backend
if [ "$GRENDERER" = "vulkan" ]; then
  sed -i '/Video:/ {n; s/Renderer: .*/Renderer: Vulkan/}' "${CONFIG_YML}"
else
  sed -i '/Video:/ {n; s/Renderer: .*/Renderer: OpenGL/}' "${CONFIG_YML}"
fi

#Internal Resolution
if [ "${FLIMIT}" = "30" ]; then
  sed -i "s#Frame limit:.*\$#Frame limit: 30#g" "${CONFIG_YML}"
elif [ "${FLIMIT}" = "60" ]; then
  sed -i "s#Frame limit:.*\$#Frame limit: 60#g" "${CONFIG_YML}"
else
  sed -i "s#Frame limit:.*\$#Frame limit: Auto#g" "${CONFIG_YML}"
fi

#Internal Resolution
if [ "${IPS3RES}" = "576" ]; then
  sed -i "s#Resolution:.*\$#Resolution: 720x576#g" "${CONFIG_YML}"
elif [ "${IPS3RES}" = "720" ]; then
  sed -i "s#Resolution:.*\$#Resolution: 1280x720#g" "${CONFIG_YML}"
elif [ "${IPS3RES}" = "1080" ]; then
  sed -i "s#Resolution:.*\$#Resolution: 1920x1080#g" "${CONFIG_YML}"
elif [ "${IPS3RES}" = "native" ]; then
  sed -i "s#Resolution:.*\$#Resolution: $(fbwidth)x$(fbheight)#g" "${CONFIG_YML}"
else
  sed -i "s#Resolution:.*\$#Resolution: 720x480#g" "${CONFIG_YML}"
fi

#Internal Resolution Scale
if [ "${IRES_SCALE}" = "25" ]; then
  sed -i "s#Resolution Scale:.*\$#Resolution Scale: 25#g" "${CONFIG_YML}"
elif [ "${IRES_SCALE}" = "75" ]; then
  sed -i "s#Resolution Scale:.*\$#Resolution Scale: 75#g" "${CONFIG_YML}"
elif [ "${IRES_SCALE}" = "100" ]; then
  sed -i "s#Resolution Scale:.*\$#Resolution Scale: 100#g" "${CONFIG_YML}"
else
  sed -i "s#Resolution Scale:.*\$#Resolution Scale: 50#g" "${CONFIG_YML}"
fi

#Multithreaded RSX
if [ "${MULTIRSX}" = "true" ]; then
  sed -i "s#Multithreaded RSX:.*\$#Multithreaded RSX: true#g" "${CONFIG_YML}"
else
  sed -i "s#Multithreaded RSX:.*\$#Multithreaded RSX: false#g" "${CONFIG_YML}"
fi

#Shader Precision
if [ "$SPREC" = "ultra" ]; then
  sed -i "s#Shader Precision:.*\$#Shader Precision: Ultra#g" "${CONFIG_YML}"
elif [ "$SPREC" = "high" ]; then
  sed -i "s#Shader Precision:.*\$#Shader Precision: High#g" "${CONFIG_YML}"
else
  sed -i "s#Shader Precision:.*\$#Shader Precision: Low#g" "${CONFIG_YML}"
fi

#SPU XFloat Accuracy
if [ "$SPUXFLOAT" = "accurate" ]; then
  sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Accurate#g" "${CONFIG_YML}"
elif [ "$SPUXFLOAT" = "relaxed" ]; then
  sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Relaxed#g" "${CONFIG_YML}"
else
  sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Approximate#g" "${CONFIG_YML}"
fi

#Write Color Buffers
if [ "${WCOLORB}" = "true" ]; then
  sed -i "s#Write Color Buffers:.*\$#Write Color Buffers: true#g" "${CONFIG_YML}"
else
  sed -i "s#Write Color Buffers:.*\$#Write Color Buffers: false#g" "${CONFIG_YML}"
fi

#Vsync
if [ "${VSYNC}" = "true" ]; then
  sed -i "s#VSync:.*\$#VSync: true#g" "${CONFIG_YML}"
else
  sed -i "s#VSync:.*\$#VSync: false#g" "${CONFIG_YML}"
fi

#Zcull Accuracy
if [ "$ZCULLA" = "precise" ]; then
  sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: false#g" "${CONFIG_YML}"
  sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: true#g" "${CONFIG_YML}"
elif [ "$ZCULLA" = "approximate" ]; then
  sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: true#g" "${CONFIG_YML}"
  sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: false#g" "${CONFIG_YML}"
else
  sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: false#g" "${CONFIG_YML}"
  sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: false#g" "${CONFIG_YML}"
fi

# Performance Overlay
if [ "${PERFOVERLAY}" = "true" ]; then
  sed -i '/Performance Overlay:/ {n; s/Enabled: .*/Enabled: true/}' "${CONFIG_YML}"
else
  sed -i '/Performance Overlay:/ {n; s/Enabled: .*/Enabled: false/}' "${CONFIG_YML}"
fi

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

#Check if its a PSN game
GAME_PATH=""
PSNID=""
if [[ "${1}" == *.psn ]]; then
  # Hardcoded now for testing
  read -r PSNID < "${1}"
  GAME_PATH="/storage/.config/rpcs3/dev_hdd0/game/${PSNID}/USRDIR/EBOOT.BIN"
elif [[ "${1}" == *.m3u ]]; then
  #check if path is M3U
  read -r M3UPATH < "${1}"
  echo ${M3UPATH}
  GAME_PATH="/roms/ps3/${M3UPATH}"
else
  GAME_PATH="${1}"
fi

#Log Settings
cat <<EOF >/var/log/rpcs3-sa.log
GAME: ${GAME}
PLATFORM: ${PLATFORM}
ASPECT RATIO: ${ASPECT}
GRU BACKEND: ${GRENDERER}
INTERNAL RESOLUTION: ${IRES}
INTERNAL RESOLUTION SCALE: ${IRES_SCALE}
MULTITHREADED RSX: ${MULTIRSX}
PERFORMANCE OVERLAY: ${PERFOVERLAY}
SHADER PRECISION: ${SPREC}
SPU XFLOAT ACCURACY: ${SPUXFLOAT}
WRITE COLOR BUFFERS: ${WCOLORB}
ZCULL ACCURACY: ${ZCULLA}
ASYNC TEXTURE STREAMING: ${ATEXTURE}
VSYNC: ${VSYNC}
SHOW UI: ${SUI}
CONFIG_YML: ${CONFIG_YML}
EOF

# Run rpcs3
if [ "$SUI" = "true" ]; then
  export QT_QPA_PLATFORM=wayland
  set_kill set "-9 rpcs3"
  ${EMUPERF} /usr/bin/rpcs3-sa
else
  export QT_QPA_PLATFORM=xcb
  set_kill set "-9 rpcs3"
  ${EMUPERF} /usr/bin/rpcs3-sa --no-gui "$GAME_PATH"
fi
