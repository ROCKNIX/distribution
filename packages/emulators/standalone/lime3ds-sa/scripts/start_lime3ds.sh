#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 lime3ds"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

# Make sure Lime3DS config directory exists
[ ! -d /storage/.config/lime3ds ] && cp -r /usr/config/lime3ds /storage/.config

# Move sdmc & nand to 3ds roms folder
[ ! -d /storage/roms/3ds/lime3ds/sdmc ] && mkdir -p /storage/roms/3ds/lime3ds/sdmc
rm -rf /storage/.config/lime3ds/sdmc
ln -sf /storage/roms/3ds/lime3ds/sdmc /storage/.config/lime3ds/sdmc

[ ! -d /storage/roms/3ds/lime3ds/nand ] && mkdir -p /storage/roms/3ds/lime3ds/nand
rm -rf /storage/.config/lime3ds/nand
ln -sf /storage/roms/3ds/lime3ds/nand /storage/.config/lime3ds/nand


# Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
CPU=$(get_setting cpu_speed "${PLATFORM}" "${GAME}")
EMOUSE=$(get_setting emulate_mouse "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
RES=$(get_setting resolution_scale "${PLATFORM}" "${GAME}")
ROTATE=$(get_setting rotate_screen "${PLATFORM}" "${GAME}")
SLAYOUT=$(get_setting screen_layout "${PLATFORM}" "${GAME}")
CSHADERS=$(get_setting cache_shaders "${PLATFORM}" "${GAME}")
HSHADERS=$(get_setting hardware_shaders "${PLATFORM}" "${GAME}")
ACCURATE_HW_SHADERS=$(get_setting accurate_hardware_shaders "${PLATFORM}" "${GAME}")

# CPU Underclock
case "${CPU}" in
  0) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 100' /storage/.config/lime3ds/sdl2-config.ini;;
  1) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 90' /storage/.config/lime3ds/sdl2-config.ini;;
  2) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 80' /storage/.config/lime3ds/sdl2-config.ini;;
  3) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 70' /storage/.config/lime3ds/sdl2-config.ini;;
  4) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 60' /storage/.config/lime3ds/sdl2-config.ini;;
  5) sed -i '/cpu_clock_percentage =/c\cpu_clock_percentage = 50' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Resolution Scale
case "${RES}" in
  0) sed -i '/resolution_factor =/c\resolution_factor = 0' /storage/.config/lime3ds/sdl2-config.ini;;
  1) sed -i '/resolution_factor =/c\resolution_factor = 1' /storage/.config/lime3ds/sdl2-config.ini;;
  2) sed -i '/resolution_factor =/c\resolution_factor = 2' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Rotate Screen
case "${ROTATE}" in
  0) sed -i '/upright_screen =/c\upright_screen = 0' /storage/.config/lime3ds/sdl2-config.ini;;
  1) sed -i '/upright_screen =/c\upright_screen = 1' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Cache Shaders
case "${CSHADERS}" in
  0) sed -i '/use_disk_shader_cache =/c\use_disk_shader_cache = 0' /storage/.config/lime3ds/sdl2-config.ini;;
  1) sed -i '/use_disk_shader_cache =/c\use_disk_shader_cache = 1' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Hardware Shaders
case "${HSHADERS}" in
  1) sed -i '/use_hw_shader =/c\use_hw_shader = 1' /storage/.config/lime3ds/sdl2-config.ini;;
  *) sed -i '/use_hw_shader =/c\use_hw_shader = 0' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Use accurate multiplication in hardware shaders
case "${ACCURATE_HW_SHADERS}" in
  1) sed -i '/shaders_accurate_mul =/c\shaders_accurate_mul = 1' /storage/.config/lime3ds/sdl2-config.ini;;
  *) sed -i '/shaders_accurate_mul =/c\shaders_accurate_mul = 0' /storage/.config/lime3ds/sdl2-config.ini;;
esac

# Screen Layout
case "${SLAYOUT}" in
  0)
    # Default (Top / Bottom)
    sed -i '/layout_option =/c\layout_option = 0' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  1a)
    # Single Screen (TOP)
    sed -i '/layout_option =/c\layout_option = 1' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  1b)
    # Single Screen (BOTTOM)
    sed -i '/layout_option =/c\layout_option = 1' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 1' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  2)
    # Large Screen, Small Screen
    sed -i '/layout_option =/c\layout_option = 2' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  3)
    # Side by Side
    sed -i '/layout_option =/c\layout_option = 3' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  4)
    # Hybrid
    sed -i '/layout_option =/c\layout_option = 5' /storage/.config/lime3ds/sdl2-config.ini
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
  5)
    # Custom Layout
    sed -i '/layout_option =/c\layout_option = 6' /storage/.config/lime3ds/sdl2-config.ini 
    sed -i '/swap_screen =/c\swap_screen = 0' /storage/.config/lime3ds/sdl2-config.ini
    ;;
esac

# Video Backend
case "${RENDERER}" in
  1) sed -i '/graphics_api =/c\graphics_api = 1' /storage/.config/lime3ds/sdl2-config.ini;;
  *) sed -i '/graphics_api =/c\graphics_api = 2' /storage/.config/lime3ds/sdl2-config.ini;;
esac

rm -rf /storage/.local/share/lime3ds
ln -sf /storage/.config/lime3ds /storage/.local/share/lime3ds

# Run Lime Emulator
if [ "${EMOUSE}" = "0" ]; then
  /usr/bin/lime3ds "${1}"
else
  ${GPTOKEYB} lime3ds -c /storage/.config/lime3ds/lime3ds.gptk &
  /usr/bin/lime3ds "${1}"
  kill -9 "$(pidof gptokeyb)"
fi
