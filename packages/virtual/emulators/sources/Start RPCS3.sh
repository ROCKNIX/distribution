#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

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

export QT_QPA_PLATFORM=xcb
set_kill set "-9 rpcs3"
sway_fullscreen "RPCS3" "class" &
/usr/bin/rpcs3-sa
