# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 xemu"

#Check if xemu exists in .config
if [ ! -d "/storage/.config/xemu" ]; then
    mkdir -p "/storage/.config/xemu"
        cp -r "/usr/config/xemu" "/storage/.config/"
fi

#Check if xemu.toml exists in .config
if [ ! -f "/storage/.config/xemu/xemu.toml" ]; then
        cp -r "/usr/config/xemu/xemu.toml" "/storage/.config/xemu/xemu.toml"
fi

#Make xemu bios folder
if [ ! -d "/storage/roms/bios/xemu/bios" ]; then
    mkdir -p "/storage/roms/bios/xemu/bios"
fi

#Make xemu eeprom folder
if [ ! -d "/storage/roms/bios/xemu/eeprom" ]; then
    mkdir -p "/storage/roms/bios/xemu/eeprom"
fi

#Make xemu hdd folder
if [ ! -d "/storage/roms/bios/xemu/hdd" ]; then
    mkdir -p "/storage/roms/bios/xemu/hdd"
fi

#Check if HDD image exists
if [ ! -f "/storage/roms/bios/xemu/hdd/xbox_hdd.qcow2" ]; then
    unzip -o /usr/config/xemu/hdd.zip -d /storage/roms/bios/xemu/hdd/
fi


CONFIG=/storage/.config/xemu/xemu.toml

/usr/share/xemu-sa/@APPIMAGE@ -full-screen -config_path $CONFIG -dvd_path "${1}"

#Workaround until we can learn why it doesn't exit cleanly when asked.
killall -9 xemu-sa
