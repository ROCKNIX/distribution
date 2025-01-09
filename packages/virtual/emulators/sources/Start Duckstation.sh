#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 duckstation-nogui"

sway_fullscreen "duckstation-nogui" "pgrep"  &

/usr/bin/duckstation-nogui -fullscreen -settings "/storage/.config/duckstation/settings.ini"
