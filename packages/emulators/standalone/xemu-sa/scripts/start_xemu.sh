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

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
#CLOCK=$(get_setting clock_speed "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
#RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
SKIPBOOT=$(get_setting skip_boot_animation "${PLATFORM}" "${GAME}")

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]; then
  		sed -i "/aspect_ratio =/c\aspect_ratio = '4x3'" /storage/.config/xemu/xemu.toml
        elif [ "$ASPECT" = "1" ]; then
                sed -i "/aspect_ratio =/c\aspect_ratio = '16x9'" /storage/.config/xemu/xemu.toml
        else
                sed -i "/aspect_ratio =/c\aspect_ratio = 'native'" /storage/.config/xemu/xemu.toml
        fi

  #Internal Resolution
        if [ "$IRES" = "2" ]; then
                sed -i "/surface_scale =/c\surface_scale = 2" /storage/.config/xemu/xemu.toml
        elif [ "$IRES" = "3" ]; then
                sed -i "/surface_scale =/c\surface_scale = 3" /storage/.config/xemu/xemu.toml
        elif [ "$IRES" = "4" ]; then
                sed -i "/surface_scale =/c\surface_scale = 4" /storage/.config/xemu/xemu.toml
        else
                sed -i "/surface_scale =/c\surface_scale = 1" /storage/.config/xemu/xemu.toml
        fi

  #Skip boot animation
        if [ "$SKIPBOOT" = "false" ]; then
                sed -i "/skip_boot_anim =/c\skip_boot_anim = false" /storage/.config/xemu/xemu.toml
        else
                sed -i "/skip_boot_anim =/c\skip_boot_anim = true" /storage/.config/xemu/xemu.toml
        fi

# Set config file location
CONFIG=/storage/.config/xemu/xemu.toml

/usr/bin/xemu -full-screen -config_path $CONFIG -dvd_path "${1}"

#Workaround until we can learn why it doesn't exit cleanly when asked.
killall -9 xemu-sa
