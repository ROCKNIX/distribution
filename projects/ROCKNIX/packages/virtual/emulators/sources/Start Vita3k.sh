#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org/)

. /etc/profile
set_kill set "-9 vita3k-sa"

CONFIG_FILE="/storage/.config/Vita3K/config.yml"

# Check if config vita3k folder exists
if [ ! -d "/storage/.config/Vita3K" ]; then
    mkdir -p "/storage/.config/Vita3K"
fi

# Copy prerequisite files if they aren't there yet.
if [ ! -d "/storage/.config/Vita3K/data" -o ! -d "/storage/.config/Vita3K/lang" -o ! -d "/storage/.config/Vita3K/shaders-builtin" ]; then
    cp -r "/usr/config/vita3k/data" "/storage/.config/Vita3K/"
    cp -r "/usr/config/vita3k/lang" "/storage/.config/Vita3K/"
    cp -r "/usr/config/vita3k/shaders-builtin" "/storage/.config/Vita3K/"
fi

# Apply default config if it isn't there yet.
if [ ! -f "${CONFIG_FILE}" ]; then
    cp -r /usr/config/vita3k/config.yml "${CONFIG_FILE}"
fi

# Check if system vita3k folder exists
if [ ! -d "/storage/roms/psvita/vita3k" ]; then
    mkdir -p "/storage/roms/psvita/vita3k"
fi

# Check for firmware files that haven't already been installed
if compgen -G "/storage/roms/bios/vita3k/*.PUP" > /dev/null; then
    for f in /storage/roms/bios/vita3k/*.PUP; do
        /usr/bin/vita3k-sa -F --firmware "${f}"
        mv "${f}" "${f}.installed"
    done
fi

# Start Vita3K
/usr/bin/vita3k-sa -F
