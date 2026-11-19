#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

### Pre-rotate the frontend and the games it starts where the plane can't rotate the mode
ES_MODE=$(cat /sys/class/drm/card*-"${WLR_CON}"/modes 2>/dev/null | head -n1)
prerotate_env "${WLR_CON_TRANSFORM}" "${ES_MODE%%x*}"

scanout_reset_stale

emulationstation --log-path /var/log --no-splash
