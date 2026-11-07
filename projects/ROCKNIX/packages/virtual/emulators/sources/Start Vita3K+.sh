#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org/)

. /etc/profile
set_kill set "-9 vita3kplus-sa"

CONFIG_FILE="/storage/.config/vita3kplus/config.yml"
LOG_FILE="/storage/.config/vita3kplus/vita3k.log"

# Check if config vita3k folder exists
if [ ! -d "/storage/.config/vita3kplus" ]; then
    mkdir -p "/storage/.config/vita3kplus"
fi

# Apply default config if it isn't there yet.
if [ ! -f "${CONFIG_FILE}" ]; then
    cp -r /usr/config/vita3kplus/config.yml "${CONFIG_FILE}"
fi

# Check if system vita3k folder exists
if [ ! -d "/storage/roms/psvita/vita3k" ]; then
    mkdir -p "/storage/roms/psvita/vita3k"
fi

# Check if bios vita3k folder exists
if [ ! -d "/storage/roms/bios/vita3k" ]; then
    mkdir -p "/storage/roms/bios/vita3k"
fi

# Check for firmware files that haven't already been installed
if compgen -G "/storage/roms/bios/vita3k/*.PUP" > /dev/null; then
    for f in /storage/roms/bios/vita3k/*.PUP; do
        /usr/bin/vita3kplus-sa --firmware "${f}" >> "${LOG_FILE}" 2>&1
        mv "${f}" "${f}.installed"
    done
fi

# Start Vita3K+
/usr/bin/vita3kplus-sa >> "${LOG_FILE}" 2>&1
