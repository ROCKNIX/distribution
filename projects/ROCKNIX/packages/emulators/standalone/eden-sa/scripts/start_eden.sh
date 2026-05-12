#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

#Check if eden exists in .config
if [ ! -d "/storage/.config/eden" ]; then
    mkdir -p "/storage/.config/eden"
        cp -r "/usr/config/eden" "/storage/.config/"
fi

#Check if qt-config.ini exists in .config/eden
if [ ! -f "/storage/.config/eden/qt-config.ini" ]; then
        cp -r "/usr/config/eden/qt-config.ini" "/storage/.config/eden/qt-config.ini"
fi

#Move Nand / Saves to switch roms folder
if [ ! -d "/storage/roms/bios/eden/nand" ]; then
    mkdir -p "/storage/roms/bios/eden/nand"
fi

rm -rf /storage/.config/eden/nand
ln -sf /storage/roms/bios/eden/nand /storage/.config/eden/nand

#Link eden keys to bios folder
if [ ! -d "/storage/roms/bios/eden/keys" ]; then
    mkdir -p "/storage/roms/bios/eden/keys"
fi

rm -rf /storage/.config/eden/keys
ln -sf /storage/roms/bios/eden/keys /storage/.config/eden/keys

#Link  .config/eden to .local
rm -rf /storage/.local/share/eden
ln -sf /storage/.config/eden /storage/.local/share/eden

#Set QT Platform to Wayland-EGL
export QT_QPA_PLATFORM=xcb

#eden won't work with the pipewire driver yet
export SDL_AUDIODRIVER=pulseaudio

set_kill set "-9 eden"

#Run eden emulator
/usr/bin/eden -f "${1}"
