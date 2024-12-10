#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

# Check if rpcs3 exists in .config
if [ ! -d "/storage/.config/rpcs3" ]; then
  mkdir -p "/storage/.config/rpcs3"
  cp -r "/usr/config/rpcs3" "/storage/.config/rpcs3"
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

# EmulationStation Features
GAME=$(echo "${1}" | sed "s#^/.*/##")
SUI=$(get_setting start_ui ps3 "${GAME}")

 Check if its a PSN game
GAME_PATH=""
PSNID=""
if [[ "${1}" == *.psn ]]; then
  # Hardcoded now for testing
  read -r PSNID < "${1}"
  GAME_PATH="/storage/.config/rpcs3/dev_hdd0/game/${PSNID}/USRDIR/EBOOT.BIN"
else
  GAME_PATH="${1}"
fi

#sed -i "s#Resolution:.*\$#Resolution: $(fbwidth)x$(fbheight)#g" /storage/.config/rpcs3/config.yml

# Run rpcs3
if [ "$SUI" = "1" ]; then
  export QT_QPA_PLATFORM=wayland
  set_kill set "-9 rpcs3"
  /usr/bin/rpcs3-sa
else
  export QT_QPA_PLATFORM=xcb
 # export SDL_AUDIODRIVER=pulseaudio
  set_kill set "-9 rpcs3"
	/usr/bin/rpcs3-sa --no-gui "$GAME_PATH"
fi
