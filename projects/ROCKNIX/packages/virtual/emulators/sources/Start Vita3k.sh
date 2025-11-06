#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

source /etc/profile

set_kill set "Vita3K"

sway_fullscreen "Vita3K" &

/usr/bin/Vita3K >/dev/null 2>&1