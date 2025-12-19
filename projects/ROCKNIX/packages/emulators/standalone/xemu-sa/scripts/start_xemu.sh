# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 xemu"

SOURCE_DIR="/usr/config/xemu"
CONF_DIR="/storage/.config/xemu"
BIOS_DIR="/storage/roms/bios/xemu"
XEMU_INI="xemu.toml"

#Check if xemu exists in .config
if [ ! -d "${CONF_DIR}" ]; then
        cp -r "${SOURCE_DIR}" "${CONF_DIR}"
fi

#Copy Xemu config at script launch
cp -r "${SOURCE_DIR}/${XEMU_INI}" "${CONF_DIR}/${XEMU_INI}"

#Make xemu bios folder
if [ ! -d "${BIOS_DIR}/bios" ]; then
    mkdir -p "${BIOS_DIR}/bios"
fi

#Make xemu eeprom folder
if [ ! -d "${BIOS_DIR}/eeprom" ]; then
    mkdir -p "${BIOS_DIR}/eeprom"
fi

#Make xemu hdd folder
if [ ! -d "${BIOS_DIR}/hdd" ]; then
    mkdir -p "${BIOS_DIR}/hdd"
fi

#Check if HDD image exists
if [ ! -f "${BIOS_DIR}/hdd/xbox_hdd.qcow2" ]; then
    unzip -o "${SOURCE_DIR}/hdd.zip" -d "${BIOS_DIR}/hdd/"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
FIT=$(get_setting fit "${PLATFORM}" "${GAME}")
CLOCK=$(get_setting cpu_clock_speed "${PLATFORM}" "${GAME}")
CSHADERS=$(get_setting cache_shaders_to_disk "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
SHOWFPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
SKIPBOOT=$(get_setting skip_boot_animation "${PLATFORM}" "${GAME}")
SMEM=$(get_setting system_memory "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")

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

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]; then
  		sed -i "/aspect_ratio =/c\aspect_ratio = '4x3'" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$ASPECT" = "1" ]; then
                sed -i "/aspect_ratio =/c\aspect_ratio = '16x9'" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/aspect_ratio =/c\aspect_ratio = 'native'" "${CONF_DIR}/${XEMU_INI}"
        fi

  #Fit
	if [ "$FIT" = "center" ]; then
                sed -i "/fit =/c\fit = 'center'" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$FIT" = "stretch" ]; then
                sed -i "/fit =/c\fit = 'stretch'" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$FIT" = "scale" ]; then
                sed -i "/fit =/c\fit = 'scale'" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/fit =/c\fit = 'integer'" "${CONF_DIR}/${XEMU_INI}"
        fi

  #Cache shaders to disk
        if [ "$CSHADERS" = "false" ]; then
                sed -i "/cache_shaders =/c\cache_shaders = false" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/cache_shaders =/c\cache_shaders = true" "${CONF_DIR}/${XEMU_INI}"
        fi

  #CPU Clock Speed
        if [ "$CLOCK" = "050" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.500000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "060" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.600000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "070" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.700000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "080" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.800000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "090" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 0.900000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "110" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.100000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "120" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.200000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "130" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.300000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "140" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.400000" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$CLOCK" = "150" ]; then
                sed -i "/override_clockspeed =/c\override_clockspeed = true" "${CONF_DIR}/${XEMU_INI}"
                sed -i "/cpu_clockspeed_scale =/c\cpu_clockspeed_scale = 1.500000" "${CONF_DIR}/${XEMU_INI}"
	else
                sed -i "/override_clockspeed =/c\override_clockspeed = false" "${CONF_DIR}/${XEMU_INI}"
	fi

  #Graphics Backend
	if [ "$GRENDERER" = "vulkan" ]; then
		sed -i "/renderer =/c\renderer = 'VULKAN'" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$GRENDERER" = "opengl" ]; then
                sed -i "/renderer =/c\renderer = 'OPENGL'" "${CONF_DIR}/${XEMU_INI}"
	else
		sed -i "/renderer =/c\renderer = '@GRENDERER@'" "${CONF_DIR}/${XEMU_INI}"
  	fi

  #Internal Resolution
        if [ "$IRES" = "2" ]; then
                sed -i "/surface_scale =/c\surface_scale = 2" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$IRES" = "3" ]; then
                sed -i "/surface_scale =/c\surface_scale = 3" "${CONF_DIR}/${XEMU_INI}"
        elif [ "$IRES" = "4" ]; then
                sed -i "/surface_scale =/c\surface_scale = 4" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/surface_scale =/c\surface_scale = 1" "${CONF_DIR}/${XEMU_INI}"
        fi

  #Show FPS
	if [ "$SHOWFPS" = "1" ]
	then
		export GALLIUM_HUD="simple,fps"
	fi

  #Skip boot animation
        if [ "$SKIPBOOT" = "false" ]; then
                sed -i "/skip_boot_anim =/c\skip_boot_anim = false" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/skip_boot_anim =/c\skip_boot_anim = true" "${CONF_DIR}/${XEMU_INI}"
        fi

  #System memory
        if [ "$SMEM" = "128" ]; then
                sed -i "/mem_limit =/c\mem_limit = '128'" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/mem_limit =/c\mem_limit = '64'" "${CONF_DIR}/${XEMU_INI}"
        fi

  #Vsync
        if [ "$VSYNC" = "false" ]; then
                sed -i "/vsync =/c\vsync = false" "${CONF_DIR}/${XEMU_INI}"
        else
                sed -i "/vsync =/c\vsync = true" "${CONF_DIR}/${XEMU_INI}"
        fi

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "ASPECT set to: ${ASPECT}"
  echo "SCREEN FIT set to: ${FIT}"
  echo "CLOCK set to: ${CLOCK}"
  echo "CACHE SHADERS set to: ${CSHADERS}"
  echo "INTERNAL RESOLUTION set to: ${IRES}"
  echo "GRAPHICS REDNERER set to: ${GRENDERER}"
  echo "SHOW FPS set to: ${SHOWFPS}"
  echo "SKIP BOOT SCREEN set to: ${SKIPBOOT}"
  echo "SYSTEM MEMORY set to: ${SMEM}"
  echo "VSYNC set to: ${VSYNC}"
  echo "CONF DIR set to: ${CONF_DIR}"
  echo "SOURCE DIR set to: ${SOURCE_DIR}"
  echo "INI set to: ${XEMU_INI}"
  echo "BIOS DIR set to: ${BIOS_DIR}"
  echo "Launching /usr/bin/xemu -fullscreen -config_path {CONF_DIR}/${XEMU_INI} -dvd_path ${1}"

# Run Xemu emulator
  ${EMUPERF} /usr/bin/xemu -full-screen -config_path "${CONF_DIR}/${XEMU_INI}" -dvd_path "${1}"
