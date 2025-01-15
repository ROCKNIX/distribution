#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "dolphin-emu"

#Retroachievements
/usr/bin/cheevos_dolphin.sh

export QT_QPA_PLATFORM=xcb

sway_fullscreen "dolphin-emu" "class" &

/usr/bin/dolphin-emu >/dev/null 2>&1
