#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

source /etc/profile

set_kill set "xemu"

# Check for Bios
if ! find /storage/roms/bios/xemu/bios -maxdepth 1 -iname '*.bin' | grep -q .; then
  /usr/bin/sdl2notify --center "Starting Xemu... \n No Bios Files Found!||Visit Rocknix.org For Instructions." 255 255 255 any
fi
# Run Xemu emulator
sway_fullscreen "xemu" &

/usr/bin/xemu >/dev/null 2>&1
