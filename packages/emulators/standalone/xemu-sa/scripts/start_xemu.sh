# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 xemu"

#Check if xemu exists in .config
if [ ! -d "/storage/.config/xemu" ]; then
    mkdir -p "/storage/.config/xemu"
        cp -r "/usr/config/xemu" "/storage/.config/"
fi

#Copy Xemu config at script launch
cp -r "/usr/config/xemu/xemu.toml" "/storage/.config/xemu/xemu.toml"

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
CLOCK=$(get_setting cpu_clock_speed "${PLATFORM}" "${GAME}")
CSHADERS=$(get_setting cache_shaders_to_disk "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
SHOWFPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
SKIPBOOT=$(get_setting skip_boot_animation "${PLATFORM}" "${GAME}")
SMEM=$(get_setting system_memory "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]; then
  		sed -i "/aspect_ratio =/c\aspect_ratio = '4x3'" /storage/.config/xemu/xemu.toml
        elif [ "$ASPECT" = "1" ]; then
                sed -i "/aspect_ratio =/c\aspect_ratio = '16x9'" /storage/.config/xemu/xemu.toml
        else
                sed -i "/aspect_ratio =/c\aspect_ratio = 'native'" /storage/.config/xemu/xemu.toml
        fi

  #Cache shaders to disk
        if [ "$CSHADERS" = "false" ]; then
                sed -i "/cache_shaders =/c\cache_shaders = false" /storage/.config/xemu/xemu.toml
        else
                sed -i "/cache_shaders =/c\cache_shaders = true" /storage/.config/xemu/xemu.toml
        fi

  #CPU Clock Speed
        if [ "$CLOCK" = "050" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.500000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "060" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.600000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "070" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.700000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "080" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.800000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "090" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.900000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "110" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.100000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "120" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.200000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "130" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.300000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "140" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.400000" /storage/.config/xemu/xemu.toml
        elif [ "$CLOCK" = "150" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" /storage/.config/xemu/xemu.toml
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.500000" /storage/.config/xemu/xemu.toml
	else
                sed -i "/override_clockspeed =/c\override_clockspeed = false" /storage/.config/xemu/xemu.toml
	fi

  #Graphics Backend
	if [ "$RENDERER" = "opengl" ]; then
		sed -i "/renderer =/c\GFXBackend = 'OPENGL'" /storage/.config/xemu/xemu.toml
	else
		sed -i "/renderer =/c\GFXBackend = 'VULKAN'" /storage/.config/xemu/xemu.toml
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

  #Show FPS
	if [ "$SHOWFPS" = "1" ]
	then
		export GALLIUM_HUD="simple,fps"
	fi

  #Skip boot animation
        if [ "$SKIPBOOT" = "false" ]; then
                sed -i "/skip_boot_anim =/c\skip_boot_anim = false" /storage/.config/xemu/xemu.toml
        else
                sed -i "/skip_boot_anim =/c\skip_boot_anim = true" /storage/.config/xemu/xemu.toml
        fi

  #System memory
        if [ "$SMEM" = "128" ]; then
                sed -i "/mem_limit =/c\mem_limit = '128'" /storage/.config/xemu/xemu.toml
        else
                sed -i "/mem_limit =/c\mem_limit = '64'" /storage/.config/xemu/xemu.toml
        fi

  #Vsync
        if [ "$VSYNC" = "false" ]; then
                sed -i "/vsync =/c\vsync = false" /storage/.config/xemu/xemu.toml
        else
                sed -i "/vsync =/c\vsync = true" /storage/.config/xemu/xemu.toml
        fi

# Set config file location
CONFIG=/storage/.config/xemu/xemu.toml

/usr/bin/xemu -full-screen -config_path $CONFIG -dvd_path "${1}"

#Workaround until we can learn why it doesn't exit cleanly when asked.
killall -9 xemu
