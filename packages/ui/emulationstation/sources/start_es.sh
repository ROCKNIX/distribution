#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

#Check if waybar exists in .config
if [ ! -d "/storage/.config/waybar" ]; then
    mkdir -p "/storage/.config/waybar"
    cp /usr/share/waybar/config.jsonc /storage/.config/waybar/config.jsonc
    cp /usr/share/waybar/style.css /storage/.config/waybar/style.css
fi

### setup is the same
. $(dirname $0)/es_settings

emulationstation --log-path /var/log --no-splash
