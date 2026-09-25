#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

### Pre-rotate the frontend and the games it starts
prerotate_env "${WLR_CON_TRANSFORM}"

scanout_reset_stale

emulationstation --log-path /var/log --no-splash
