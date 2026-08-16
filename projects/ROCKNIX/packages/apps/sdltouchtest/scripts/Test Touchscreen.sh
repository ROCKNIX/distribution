#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "-9 sdltouchtest"

/usr/bin/sdl2notify "Touchscreen Test \n ||To Exit Hold L1 & Press START + SELECT" 255 255 255 any

/usr/bin/sdltouchtest
