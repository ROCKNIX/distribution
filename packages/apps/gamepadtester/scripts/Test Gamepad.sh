#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "gamepad-tester"

sway_fullscreen "gamepad-tester" &

/usr/bin/gamepad-tester
