#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

GAME="${1}"
CONFIG_FILE="/storage/.config/Vita3K/config.yml"

. /etc/profile
set_kill set "-9 vita3k-sa"

# Bail on error, especially since .pkg installation calls can fail if the ZRIF is wrong,
# and that could cause data loss/confusion with the second call on Vita3K...
set -e

# Check if config vita3k folder exists
if [ ! -d "/storage/.config/Vita3K" ]; then
    mkdir -p "/storage/.config/Vita3K"
fi

# Apply default config if it isn't there yet.
if [ ! -f "${CONFIG_FILE}" ]; then
    cp "/usr/config/vita3k/config.yml" "${CONFIG_FILE}"
fi

# Copy vita-gamelist for game scanning if not already there.
if [ ! -f "/storage/.config/Vita3K/vita-gamelist.txt" ]; then
    cp "/usr/config/vita3k/vita-gamelist.txt" "/storage/.config/Vita3K/"
fi

# EmulationStation options
ROMNAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM="${2}"
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${ROMNAME}")
PSTVMODE=$(get_setting pstv_mode "${PLATFORM}" "${ROMNAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${ROMNAME}")
FILTER=$(get_setting bilinear_filtering "${PLATFORM}" "${ROMNAME}")
ACCURACY=$(get_setting high_accuracy "${PLATFORM}" "${ROMNAME}")
MEMMAPPING=$(get_setting memory_mapping "${PLATFORM}" "${ROMNAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${ROMNAME}")
ANISO=$(get_setting anisotropic_filtering "${PLATFORM}" "${ROMNAME}")
FPSHACK=$(get_setting fps_hack "${PLATFORM}" "${ROMNAME}")
NGSENABLE=$(get_setting ngs_audio "${PLATFORM}" "${ROMNAME}")
DISABLEMOTION=$(get_setting disable_gyro "${PLATFORM}" "${ROMNAME}")
DISABLESURFACESYNC=$(get_setting disable_surface_sync "${PLATFORM}" "${ROMNAME}")
SYSBUTTON=$(get_setting confirm_button "${PLATFORM}" "${ROMNAME}")
FILELOADINGDELAY=$(get_setting file_loading_delay "${PLATFORM}" "${ROMNAME}")
SPIRVSHADER=$(get_setting spirv_shader "${PLATFORM}" "${ROMNAME}")
HASHLESSTEXCACHE=$(get_setting hashless_texture_cache "${PLATFORM}" "${ROMNAME}")
HTTPENABLE=$(get_setting network_features "${PLATFORM}" "${ROMNAME}")

# Graphics Backend
if [ "${RENDERER}" = "opengl" ]; then
  sed -i "/^backend-renderer:/c\backend-renderer: OpenGL" /storage/.config/Vita3K/config.yml
else
  sed -i "/^backend-renderer:/c\backend-renderer: Vulkan" /storage/.config/Vita3K/config.yml
fi

# Internal Resolution
if [ "$IRES" = "0.5" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 0.5" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "0.75" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 0.75" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.25" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.25" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.5" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.5" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.75" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.75" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "2" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 2" /storage/.config/Vita3K/config.yml
else
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1" /storage/.config/Vita3K/config.yml
fi

# PSTV Mode
if [ "${PSTVMODE}" = "true" ]; then
  sed -i "/^pstv-mode:/c\pstv-mode: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^pstv-mode:/c\pstv-mode: false" /storage/.config/Vita3K/config.yml
fi

# Bilinear Filtering
if [ "${FILTER}" = "0" ]; then
  sed -i '/^screen-filter:/c\screen-filter: Nearest' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "2" ]; then
  sed -i '/^screen-filter:/c\screen-filter: Bicubic' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "3" ]; then
  sed -i '/^screen-filter:/c\screen-filter: FXAA' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "4" ]; then
  sed -i '/^screen-filter:/c\screen-filter: FSR' /storage/.config/Vita3K/config.yml
else
  sed -i '/^screen-filter:/c\screen-filter: Bilinear' /storage/.config/Vita3K/config.yml
fi

# Renderer Accuracy
if [ "${ACCURACY}" = "true" ]; then
  sed -i "/^high-accuracy:/c\high-accuracy: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^high-accuracy:/c\high-accuracy: false" /storage/.config/Vita3K/config.yml
fi

# Memory Mapping
if [ -n "${MEMMAPPING}" ]; then
  sed -i "/^memory-mapping:/c\memory-mapping: ${MEMMAPPING}" /storage/.config/Vita3K/config.yml
else
  sed -i "/^memory-mapping:/c\memory-mapping: double-buffer" /storage/.config/Vita3K/config.yml
fi

# Vsync
if [ "${VSYNC}" = "false" ]; then
  sed -i "/^v-sync:/c\v-sync: false" /storage/.config/Vita3K/config.yml
else
  sed -i "/^v-sync:/c\v-sync: true" /storage/.config/Vita3K/config.yml
fi

# Anisotropic Filtering
if [ -n "${ANISO}" ]; then
  sed -i "/^anisotropic-filtering:/c\anisotropic-filtering: ${ANISO}" /storage/.config/Vita3K/config.yml
else
  sed -i "/^anisotropic-filtering:/c\anisotropic-filtering: 1" /storage/.config/Vita3K/config.yml
fi

# FPS Hack
if [ "${FPSHACK}" = "true" ]; then
  sed -i "/^fps-hack:/c\fps-hack: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^fps-hack:/c\fps-hack: false" /storage/.config/Vita3K/config.yml
fi

# NGS Audio Engine
if [ "${NGSENABLE}" = "false" ]; then
  sed -i "/^ngs-enable:/c\ngs-enable: false" /storage/.config/Vita3K/config.yml
else
  sed -i "/^ngs-enable:/c\ngs-enable: true" /storage/.config/Vita3K/config.yml
fi

# Disable Motion Controls
if [ "${DISABLEMOTION}" = "true" ]; then
  sed -i "/^disable-motion:/c\disable-motion: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^disable-motion:/c\disable-motion: false" /storage/.config/Vita3K/config.yml
fi

# Disable Surface Sync
if [ "${DISABLESURFACESYNC}" = "false" ]; then
  sed -i "/^disable-surface-sync:/c\disable-surface-sync: false" /storage/.config/Vita3K/config.yml
else
  sed -i "/^disable-surface-sync:/c\disable-surface-sync: true" /storage/.config/Vita3K/config.yml
fi

# System Confirm Button
if [ "${SYSBUTTON}" = "0" ]; then
  sed -i "/^sys-button:/c\sys-button: 0" /storage/.config/Vita3K/config.yml
else
  sed -i "/^sys-button:/c\sys-button: 1" /storage/.config/Vita3K/config.yml
fi

# File Loading Delay
if [ -n "${FILELOADINGDELAY}" ]; then
  sed -i "/^file-loading-delay:/c\file-loading-delay: ${FILELOADINGDELAY}" /storage/.config/Vita3K/config.yml
else
  sed -i "/^file-loading-delay:/c\file-loading-delay: 0" /storage/.config/Vita3K/config.yml
fi

# SPIR-V Shader Path
if [ "${SPIRVSHADER}" = "true" ]; then
  sed -i "/^spirv-shader:/c\spirv-shader: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^spirv-shader:/c\spirv-shader: false" /storage/.config/Vita3K/config.yml
fi

# Hashless Texture Cache
if [ "${HASHLESSTEXCACHE}" = "true" ]; then
  sed -i "/^hashless-texture-cache:/c\hashless-texture-cache: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^hashless-texture-cache:/c\hashless-texture-cache: false" /storage/.config/Vita3K/config.yml
fi

# HTTP Networking
if [ "${HTTPENABLE}" = "true" ]; then
  sed -i "/^http-enable:/c\http-enable: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^http-enable:/c\http-enable: false" /storage/.config/Vita3K/config.yml
fi

# Check if system vita3k folder exists, which needs to be populated by Vita3K before we can do anything.
if [ ! -d "/storage/roms/psvita/vita3k" ]; then
    text_viewer -w -f 64 -t "Vita3K Setup Required" -m "Please launch Vita3K from the Tools menu first to initialize its data folder."
    exit 1
fi

# If there aren't any installed firmware files, let the user know that it's gonna be weird...
if ! compgen -G "/storage/roms/bios/vita3k/*.PUP.installed" > /dev/null; then
    mako-notify "No firmware has been installed yet! Emulation may be unstable..." -no-es
fi

# Handle file types depending on extension
# .pkg: Check for a matching .txt with the same name and hope it contains the required ZRIF,
#       then install the game, scan to create the .psvita entry, then rename the now
#       redundant .pkg file since the game is now in the vita3k system folder.
# .zip: Pass directly to Vita3K since no decryption is needed, then scan on exit to create
#       the .psvita entry, and also rename the redundant .zip file. Same reasoning as .pkg files.
# .psvita: This game is already installed, just pass the ID contained in it to Vita3K.
# TODO: Maybe add a cleanup script for .installed GAME files (not firmware since we need to be able to
#       tell if they've been installed yet), if the user wants to reclaim space?
#       Probably not polite to just delete them automatically, even if they aren't needed anymore.

# Snapshot the installed games, so we can see if one was just installed for later.
APPS_BEFORE=$(ls /storage/roms/psvita/vita3k/ux0/app/ 2>/dev/null)
NEW_ID=""

case "$GAME" in
    *.pkg)
        # Check for the matching .txt file with the ZRIF, and if it's not there, bail since we literally can't install a .pkg without it.
        if [ ! -f "${GAME%.pkg}.txt" ]; then
            text_viewer -w -f 64 -t "ZRIF Required" -m "A .txt file with the same name as the .pkg and containing the ZRIF string is required to install and play this game. Please place it next to the .pkg file and try again."
            exit 1
        fi

        # Install the requested game and scan so the next gamelist update catches it.
        # Spawn with foot so that output displays as the game is installed, letting the user know something is happening.
        foot /usr/bin/vita3k-sa -F --pkg "${GAME}" --zrif "$(cat "${GAME%.pkg}.txt")"
        /usr/bin/scan_vita3k.sh

        # Get the newly installed game's ID and run it!
        NEW_ID=$(grep -vxFf <(echo "$APPS_BEFORE") <(ls /storage/roms/psvita/vita3k/ux0/app/) | head -1)
        /usr/bin/vita3k-sa -F -E -r "${NEW_ID}"

        # Mark them as installed so they don't get caught by any other scans or get put in the gamelist more than once.
        mv "${GAME}" "${GAME}.installed"
        mv "${GAME%.pkg}.txt" "${GAME%.pkg}.txt.installed"
        ;;
    *.zip)
        # Vita3K needs to be run in the folder of the game to install if it's a .zip... for some reason.
        cd "/storage/roms/psvita"

        # Otherwise, reasoning applies similarly for .zip files, but they're packaged with a ZRIF and actually run immediately.
        foot /usr/bin/vita3k-sa -F -E "${ROMNAME}"
        /usr/bin/scan_vita3k.sh

        # Store the new game's ID for the check later.
        NEW_ID=$(grep -vxFf <(echo "$APPS_BEFORE") <(ls /storage/roms/psvita/vita3k/ux0/app/) | head -1)
        mv "${GAME}" "${GAME%.zip}.installed"
        ;;
    *.psvita)
        /usr/bin/vita3k-sa -F -E -r "$(cat "${GAME}")"
        ;;
esac

# Check if we got a new game, or just launched one that was already installed to forcefully update the gamelist.
if [ -n "${NEW_ID}" ]; then
    # TODO: Don't do this. Find a better way if possible.
    killall emulationstation || true
fi
