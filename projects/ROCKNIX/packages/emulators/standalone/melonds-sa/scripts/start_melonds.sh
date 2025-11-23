#!/bin/bash

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 melonDS"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

CONF_DIR="/storage/.config/melonDS"
MELONDS_INI="${CONF_DIR}/melonDS.ini"
SWAY_CONFIG="/storage/.config/sway/config"

# INI Setter
set_ini() {
    key="$1"
    value="$2"
    file="$3"

    if grep -q "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

# Create config directory if missing
if [ ! -d "${CONF_DIR}" ]; then
    cp -r "/usr/config/melonDS" "/storage/.config"
fi

# Create savestate directory
mkdir -p "/storage/roms/savestates/nds"

# Ensure melonDS.gptk exists
if [ ! -f "${CONF_DIR}/melonDS.gptk" ]; then
    cp "/usr/config/melonDS/melonDS.gptk" "${CONF_DIR}/melonDS.gptk"
fi

# Emulation Station Features
GAME=$(basename "${1}")
PLATFORM=$(basename "${2}")

GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
SORIENTATION=$(get_setting screen_orientation "${PLATFORM}" "${GAME}")
SLAYOUT=$(get_setting screen_layout "${PLATFORM}" "${GAME}")
SWAP=$(get_setting screen_swap "${PLATFORM}" "${GAME}")
SROTATION=$(get_setting screen_rotation "${PLATFORM}" "${GAME}")
SHOWFPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")

# CPU Cores
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
unset EMUPERF
[ "${CORES}" = "little" ] && EMUPERF="${SLOW_CORES}"
[ "${CORES}" = "big" ] && EMUPERF="${FAST_CORES}"

# Graphics Backend
if [ "$GRENDERER" -gt "0" ]; then
    set_ini ScreenUseGL "$GRENDERER" "${MELONDS_INI}"
    set_ini 3DRenderer "1" "${MELONDS_INI}"
else
    set_ini ScreenUseGL "0" "${MELONDS_INI}"
    set_ini 3DRenderer "0" "${MELONDS_INI}"
fi

# Internal Resolution
if [ "$IRES" -gt "0" ]; then
    set_ini GL_ScaleFactor "$IRES" "${MELONDS_INI}"
else
    set_ini GL_ScaleFactor "1" "${MELONDS_INI}"
fi

# Screen Orientation
if [ "$SORIENTATION" -gt "0" ]; then
    set_ini ScreenLayout "$SORIENTATION" "${MELONDS_INI}"
else
    set_ini ScreenLayout "2" "${MELONDS_INI}"
fi

# Screen Layout (defaults)
set_ini Screen1Enabled "0" "${MELONDS_INI}"

enable_second_screen() {
    set_ini ScreenSizing "4" "${MELONDS_INI}"
    set_ini Screen1Enabled "1" "${MELONDS_INI}"
}

if [ "$SLAYOUT" = "6" ]; then
    enable_second_screen
elif [ -n "$SLAYOUT" ] && [ "$SLAYOUT" != "0" ]; then
    set_ini ScreenSizing "$SLAYOUT" "${MELONDS_INI}"
elif [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    enable_second_screen
else
    set_ini ScreenSizing "0" "${MELONDS_INI}"
fi

# Screen Swap
if [[ "${DEVICE_HAS_DUAL_SCREEN}" = "true" && ( -z "$SLAYOUT" || "$SLAYOUT" = "6" ) ]]; then
    if [ "$SWAP" = "1" ]; then
        set_ini ScreenSizing "5" "${MELONDS_INI}"
        set_ini Screen1Sizing "4" "${MELONDS_INI}"
    else
        set_ini ScreenSizing "4" "${MELONDS_INI}"
        set_ini Screen1Sizing "5" "${MELONDS_INI}"
    fi
else
    set_ini ScreenSwap "${SWAP:-0}" "${MELONDS_INI}"
fi

# Screen Rotation
if [ "$SROTATION" -gt "0" ]; then
    set_ini ScreenRotation "$SROTATION" "${MELONDS_INI}"
else
    set_ini ScreenRotation "0" "${MELONDS_INI}"
fi

# Vsync
set_ini ScreenVSync "${VSYNC:-1}" "${MELONDS_INI}"

# Show FPS
if [ "$SHOWFPS" = "1" ]; then
    export GALLIUM_HUD="simple,fps"
fi

# Extract archive
TEMP="/tmp/melonds"
rm -rf "${TEMP}"
mkdir -p "${TEMP}"

if [[ "${1}" == *.zip ]]; then
    unzip -o "${1}" -d "${TEMP}"
    ROM=$(find "${TEMP}" -maxdepth 1 -name "*.nds" | head -n 1)
elif [[ "${1}" == *.7z ]]; then
    7z x -y -o"${TEMP}" "${1}"
    ROM=$(find "${TEMP}" -maxdepth 1 -name "*.nds" | head -n 1)
else
    ROM="${1}"
fi

# QT Wayland
export QT_QPA_PLATFORM=xcb
@PANFROST@
@HOTKEY@
@LIBMALI@

# Regenerate TOML
rm -f "${CONF_DIR}/melonDS.toml"

# Launch emulator
$GPTOKEYB "melonDS" -c "${CONF_DIR}/melonDS.gptk" &
${EMUPERF} /usr/bin/melonDS -f "${ROM}"
kill -9 "$(pidof gptokeyb)"
