#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "commander"

sway_fullscreen "commander" &

/usr/bin/commander
