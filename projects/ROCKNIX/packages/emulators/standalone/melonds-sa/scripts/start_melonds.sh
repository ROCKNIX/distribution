#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 melonDS"

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

CONF_DIR="/storage/.config/melonDS"
MELONDS_INI="melonDS.ini"
SWAY_CONFIG="/storage/.config/sway/config"

if [ ! -d "${CONF_DIR}" ]; then
	cp -r "/usr/config/melonDS" "/storage/.config/"
fi

if [ ! -d "/storage/roms/savestates/nds" ]; then
	mkdir -p "/storage/roms/savestates/nds"
fi

#Make sure melonDS gptk config exists
if [ ! -f "${CONF_DIR}/melonDS.gptk" ]; then
	cp -r "/usr/config/melonDS/melonDS.gptk" "${CONF_DIR}/melonDS.gptk"
fi

#Make sure melonDS config exists
if [ ! -f "${CONF_DIR}/${MELONDS_INI}" ]; then
	cp -r "/usr/config/melonDS/melonDS.ini" "${CONF_DIR}/${MELONDS_INI}"
fi

# Bind player 1 by position from its ES mapping (AMD64 has no fixed pad)
if [ "${HW_DEVICE}" = "AMD64" ] && mkcontroller; then
  . /storage/.config/profile.d/098-controller
  # melonDS: button, or 0x100|hat<<4|dir, in the low 16 bits; 0x10000|axis<<24|dir<<20 above
  mds() {
    case "$1" in
      "") echo -1 ;;
      h*) local d; case "${1:2}" in up) d=1 ;; right) d=2 ;; down) d=4 ;; *) d=8 ;; esac
          echo $(( 0x100 | ${1:1:1} << 4 | d )) ;;
      *-) echo $(( 0xFFFF | 0x10000 | ${1%?} << 24 | 1 << 20 )) ;;
      *+) echo $(( 0xFFFF | 0x10000 | ${1%?} << 24 )) ;;
      *) echo "$1" ;;
    esac
  }
  # D-pad direction plus the matching left stick direction
  mds_dir() { local b=$(mds "$1") a=0; [ -n "$2" ] && a=$(( $(mds "$2") & ~0xFFFF )); echo $(( (b & 0xFFFF) | a )); }
  INI="${CONF_DIR}/${MELONDS_INI}"
  for kv in "Joy_A=$(mds ${DEVICE_BTN_EAST})" "Joy_B=$(mds ${DEVICE_BTN_SOUTH})" "Joy_X=$(mds ${DEVICE_BTN_NORTH})" \
            "Joy_Y=$(mds ${DEVICE_BTN_WEST})" "Joy_L=$(mds ${DEVICE_BTN_TL})" "Joy_R=$(mds ${DEVICE_BTN_TR})" \
            "Joy_Select=$(mds ${DEVICE_BTN_SELECT})" "Joy_Start=$(mds ${DEVICE_BTN_START})" \
            "Joy_Up=$(mds_dir "${DEVICE_BTN_DPAD_UP}" "${DEVICE_BTN_AL_UP}")" "Joy_Down=$(mds_dir "${DEVICE_BTN_DPAD_DOWN}" "${DEVICE_BTN_AL_DOWN}")" \
            "Joy_Left=$(mds_dir "${DEVICE_BTN_DPAD_LEFT}" "${DEVICE_BTN_AL_LEFT}")" "Joy_Right=$(mds_dir "${DEVICE_BTN_DPAD_RIGHT}" "${DEVICE_BTN_AL_RIGHT}")" \
            "HKJoy_HotkeyEnable=$(mds ${DEVICE_BTN_MODE:-${DEVICE_BTN_SELECT}})" "HKJoy_SaveState=$(mds ${DEVICE_BTN_TR})" \
            "HKJoy_LoadState=$(mds ${DEVICE_BTN_TL})" "HKJoy_FastForwardToggle=$(mds ${DEVICE_BTN_TR2})" \
            "HKJoy_SwapScreenEmphasis=$(mds ${DEVICE_BTN_TL2})"; do
    sed -i "s/^${kv%%=*}=.*/${kv}/" "${INI}"
  done
fi

#Emulation Station Features
GAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
CONTYPE=$(get_setting console_type "${PLATFORM}" "${GAME}")
DBOOT=$(get_setting direct_boot "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
SORIENTATION=$(get_setting screen_orientation "${PLATFORM}" "${GAME}")
SLAYOUT=$(get_setting screen_layout "${PLATFORM}" "${GAME}")
SWAP=$(get_setting screen_swap "${PLATFORM}" "${GAME}")
SROTATION=$(get_setting screen_rotation "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
unset EMUPERF
[ "${CORES}" = "little" ] && EMUPERF="${SLOW_CORES}"
[ "${CORES}" = "big" ] && EMUPERF="${FAST_CORES}"

#Console Type
if [ "$PLATFORM" = "ndsiware" ]; then
    sed -i '/^ConsoleType=/c\ConsoleType=1' /storage/.config/melonDS/melonDS.ini
else
    if [ "$CONTYPE" = "1" ]; then
        sed -i '/^ConsoleType=/c\ConsoleType=1' /storage/.config/melonDS/melonDS.ini
    else
        sed -i '/^ConsoleType=/c\ConsoleType=0' /storage/.config/melonDS/melonDS.ini
    fi
fi

#Direct Boot
if [ "$PLATFORM" = "ndsiware" ]; then
    sed -i '/^DirectBoot=/c\DirectBoot=0' /storage/.config/melonDS/melonDS.ini
else
    if [ "$DBOOT" = "0" ]; then
        sed -i '/^DirectBoot=/c\DirectBoot=0' /storage/.config/melonDS/melonDS.ini
        sed -i '/^ExternalBIOSEnable=/c\ExternalBIOSEnable=1' /storage/.config/melonDS/melonDS.ini
    else
        sed -i '/^DirectBoot=/c\DirectBoot=1' /storage/.config/melonDS/melonDS.ini
        sed -i '/^ExternalBIOSEnable=/c\ExternalBIOSEnable=0' /storage/.config/melonDS/melonDS.ini
    fi
fi

#Graphics Backend
case "$GRENDERER" in
  "1"|"2")
    sed -i "/^ScreenUseGL=/c\ScreenUseGL=1" "${CONF_DIR}/${MELONDS_INI}"
    sed -i "/^3DRenderer=/c\3DRenderer=$GRENDERER" "${CONF_DIR}/${MELONDS_INI}"
  ;;
  *)
    sed -i '/^ScreenUseGL=/c\ScreenUseGL=0' "${CONF_DIR}/${MELONDS_INI}"
    sed -i '/^3DRenderer=/c\3DRenderer=0' "${CONF_DIR}/${MELONDS_INI}"
  ;;
esac

#Internal Resolution
if [ "$IRES" > "0" ]; then
        sed -i "/^GL_ScaleFactor=/c\GL_ScaleFactor=$IRES" "${CONF_DIR}/${MELONDS_INI}"
else
        sed -i '/^GL_ScaleFactor=/c\GL_ScaleFactor=1' "${CONF_DIR}/${MELONDS_INI}"
fi

#Screen Orientation
if [ "$SORIENTATION" > "0" ]; then
	sed -i "/^ScreenLayout=/c\ScreenLayout=$SORIENTATION" "${CONF_DIR}/${MELONDS_INI}"
else
	sed -i '/^ScreenLayout=/c\ScreenLayout=2' "${CONF_DIR}/${MELONDS_INI}"
fi

#Screen Layout
# Screen Layout
sed -i '/^Screen1Enabled=/c\Screen1Enabled=0' "${CONF_DIR}/${MELONDS_INI}"

enable_second_screen() {
    sed -i '/^ScreenSizing=/c\ScreenSizing=4' "${CONF_DIR}/${MELONDS_INI}"
    sed -i '/^Screen1Enabled=/d$ a Screen1Enabled=1' "${CONF_DIR}/${MELONDS_INI}"
    sed -i '/^Screen1Layout=/d$ a Screen1Layout=2' "${CONF_DIR}/${MELONDS_INI}"
}

if [ "$SLAYOUT" = "6" ]; then
    enable_second_screen
elif [ -n "$SLAYOUT" ] && [ "$SLAYOUT" != "0" ]; then
    sed -i "/^ScreenSizing=/c\ScreenSizing=$SLAYOUT" "${CONF_DIR}/${MELONDS_INI}"
elif [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    enable_second_screen
else
    sed -i '/^ScreenSizing=/c\ScreenSizing=0' "${CONF_DIR}/${MELONDS_INI}"
fi

# Screen Swap
if [[ "${DEVICE_HAS_DUAL_SCREEN}" = "true" && ( -z "$SLAYOUT" || "$SLAYOUT" = "6" ) ]]; then
    if [ "$SWAP" = "1" ]; then
        sed -i '/^ScreenSizing=/c\ScreenSizing=5' "${CONF_DIR}/${MELONDS_INI}"
        sed -i '/^Screen1Sizing=/d$ a Screen1Sizing=4' "${CONF_DIR}/${MELONDS_INI}"
    else
        sed -i '/^ScreenSizing=/c\ScreenSizing=4' "${CONF_DIR}/${MELONDS_INI}"
        sed -i '/^Screen1Sizing=/d$ a Screen1Sizing=5' "${CONF_DIR}/${MELONDS_INI}"
    fi
else
    sed -i "/^ScreenSwap=/c\ScreenSwap=${SWAP:-0}" "${CONF_DIR}/${MELONDS_INI}"
fi

#Screen Rotation
if [ "$SROTATION" ] >"0"; then
	sed -i "/^ScreenRotation=/c\ScreenRotation=$SROTATION" "${CONF_DIR}/${MELONDS_INI}"
else
	sed -i '/^ScreenRotation=/c\ScreenRotation=0' "${CONF_DIR}/${MELONDS_INI}"
fi

#Vsync
if [ "$VSYNC" = "1" ]; then
	sed -i '/^ScreenVSync=/c\ScreenVSync=1' "${CONF_DIR}/${MELONDS_INI}"
else
	sed -i '/^ScreenVSync=/c\ScreenVSync=0' "${CONF_DIR}/${MELONDS_INI}"
fi

# Extract archive to /tmp/melonds
TEMP="/tmp/melonds"
rm -rf "${TEMP}"
mkdir -p "${TEMP}"
if [[ "${1}" == *.zip ]]; then
    unzip -o "${1}" -d "${TEMP}"
    ROM=$(find "${TEMP}" -maxdepth 1 -type f -name "*.nds" | head -n 1)
elif [[ "${1}" == *.7z ]]; then
    7z x -y -o"${TEMP}" "${1}"
    ROM=$(find "${TEMP}" -maxdepth 1 -type f -name "*.nds" | head -n 1)
else
    ROM="${1}"
fi

# QT platform - default to xcb
export QT_QPA_PLATFORM=xcb

# QT platform - some device / driver combinations need wayland
case ${HW_DEVICE} in
    RK3566|RK3588|S922X)
        [[ $(/usr/bin/gpudriver) == "libmali" ]] && export QT_QPA_PLATFORM=wayland
    ;;
esac

@PANFROST@
@HOTKEY@
@LIBMALI@

#Generate a new MelonDS.toml each run (temporary hack)
rm -rf "${CONF_DIR}/melonDS.toml"

#Retroachievements
/usr/bin/cheevos_melonds.sh

#Run MelonDS emulator
$GPTOKEYB "melonDS" -c "${CONF_DIR}/melonDS.gptk" &
${EMUPERF} /usr/bin/melonDS -f "${ROM}"
kill -9 "$(pidof gptokeyb)"
